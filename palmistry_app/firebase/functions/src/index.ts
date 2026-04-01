import * as functions from "firebase-functions";
import { defineSecret } from "firebase-functions/params";
import Anthropic from "@anthropic-ai/sdk";

const claudeApiKey = defineSecret("CLAUDE_API_KEY");

function getAnthropicClient(): Anthropic {
  return new Anthropic({ apiKey: claudeApiKey.value() });
}

// ---------------------------------------------------------------------------
// Security: API key validation
// ---------------------------------------------------------------------------

const API_SECRET =
  process.env.APP_API_SECRET || functions.config().app?.api_secret || "";

function validateRequest(req: functions.https.Request): string | null {
  const authHeader = req.headers["x-api-key"];
  if (!API_SECRET) return null; // No secret configured = skip check (dev mode)
  if (authHeader !== API_SECRET) return "Unauthorized";
  return null;
}

// ---------------------------------------------------------------------------
// Security: In-memory rate limiting
// ---------------------------------------------------------------------------

const rateLimiter = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT = 20; // requests per window
const RATE_WINDOW_MS = 60 * 60 * 1000; // 1 hour

function checkRateLimit(identifier: string): boolean {
  const now = Date.now();
  const entry = rateLimiter.get(identifier);
  if (!entry || now > entry.resetAt) {
    rateLimiter.set(identifier, { count: 1, resetAt: now + RATE_WINDOW_MS });
    return true;
  }
  if (entry.count >= RATE_LIMIT) return false;
  entry.count++;
  return true;
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface InterpretPalmRequest {
  systemPrompt: string;
  userPrompt: string;
}

interface InterpretPalmFollowupRequest {
  systemPrompt: string;
  messages: Array<{ role: "user" | "assistant"; content: string }>;
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const MODEL = "claude-sonnet-4-20250514";
const MAX_TOKENS = 2048;
const MAX_JSON_RETRIES = 2;
const MAX_PROMPT_LENGTH = 10000;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Attempts to extract a valid JSON object from Claude's response text.
 * Strips optional markdown code fences if present.
 */
function extractJson(text: string): string {
  const trimmed = text.trim();

  // Strip markdown code fences: ```json ... ``` or ``` ... ```
  const fenceMatch = trimmed.match(/^```(?:json)?\s*([\s\S]*?)```\s*$/);
  if (fenceMatch) {
    return fenceMatch[1].trim();
  }

  return trimmed;
}

/**
 * Validates that the given string parses as a JSON object with expected fields
 * for a palm reading interpretation response.
 */
function isValidInterpretationJson(text: string): boolean {
  try {
    const parsed = JSON.parse(text);
    return (
      typeof parsed === "object" &&
      parsed !== null &&
      typeof parsed.overview === "string" &&
      typeof parsed.lineAnalysis === "string" &&
      typeof parsed.advice === "string"
    );
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// interpretPalm — main palm reading interpretation endpoint
// ---------------------------------------------------------------------------

export const interpretPalm = functions
  .runWith({ timeoutSeconds: 60, memory: "256MB", secrets: [claudeApiKey] })
  .https.onRequest(async (req, res) => {
    // Flutter app is not a browser — no wildcard CORS needed.
    // Allow OPTIONS only for local emulator preflight compatibility.
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    // Auth check
    const authError = validateRequest(req);
    if (authError) {
      const ip = req.ip || "unknown";
      functions.logger.warn("interpretPalm: unauthorized request", { ip });
      res.status(401).json({ error: authError });
      return;
    }

    // Rate limiting by IP
    const clientIp = req.ip || "unknown";
    if (!checkRateLimit(clientIp)) {
      functions.logger.warn("interpretPalm: rate limit exceeded", {
        ip: clientIp,
      });
      res.status(429).json({ error: "Too many requests. Please try again later." });
      return;
    }

    const { systemPrompt, userPrompt } = req.body as InterpretPalmRequest;

    if (!systemPrompt || !userPrompt) {
      res
        .status(400)
        .json({ error: "systemPrompt and userPrompt are required" });
      return;
    }

    // Input length validation
    if (
      systemPrompt.length > MAX_PROMPT_LENGTH ||
      userPrompt.length > MAX_PROMPT_LENGTH
    ) {
      res.status(400).json({ error: "Input too long" });
      return;
    }

    let attempt = 0;
    let lastError = "";

    while (attempt <= MAX_JSON_RETRIES) {
      try {
        const retryNote =
          attempt > 0
            ? `\n\nПредыдущий ответ содержал невалидный JSON. Пожалуйста, верни ТОЛЬКО валидный JSON без дополнительного текста. Ошибка: ${lastError}`
            : "";

        const message = await getAnthropicClient().messages.create({
          model: MODEL,
          max_tokens: MAX_TOKENS,
          system: systemPrompt,
          messages: [
            {
              role: "user",
              content: userPrompt + retryNote,
            },
          ],
        });

        const rawText =
          message.content[0].type === "text" ? message.content[0].text : "";

        const jsonText = extractJson(rawText);

        if (!isValidInterpretationJson(jsonText)) {
          lastError = `Missing required fields. Raw: ${jsonText.slice(0, 200)}`;
          attempt++;
          continue;
        }

        res.status(200).json({ interpretation: jsonText });
        return;
      } catch (err) {
        const errMsg = err instanceof Error ? err.message : String(err);
        functions.logger.error("Claude API error on attempt", attempt, errMsg);
        lastError = errMsg;
        attempt++;
      }
    }

    functions.logger.error(
      "interpretPalm: all retries exhausted",
      lastError
    );
    res.status(502).json({
      error: "Failed to get valid interpretation from Claude",
      details: lastError,
    });
  });

// ---------------------------------------------------------------------------
// interpretPalmFollowup — follow-up chat endpoint
// ---------------------------------------------------------------------------

export const interpretPalmFollowup = functions
  .runWith({ timeoutSeconds: 60, memory: "256MB", secrets: [claudeApiKey] })
  .https.onRequest(async (req, res) => {
    // Flutter app is not a browser — no wildcard CORS needed.
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    // Auth check
    const authError = validateRequest(req);
    if (authError) {
      const ip = req.ip || "unknown";
      functions.logger.warn("interpretPalmFollowup: unauthorized request", {
        ip,
      });
      res.status(401).json({ error: authError });
      return;
    }

    // Rate limiting by IP
    const clientIp = req.ip || "unknown";
    if (!checkRateLimit(clientIp)) {
      functions.logger.warn("interpretPalmFollowup: rate limit exceeded", {
        ip: clientIp,
      });
      res.status(429).json({ error: "Too many requests. Please try again later." });
      return;
    }

    const { systemPrompt, messages } =
      req.body as InterpretPalmFollowupRequest;

    if (!systemPrompt || !messages || !Array.isArray(messages)) {
      res
        .status(400)
        .json({ error: "systemPrompt and messages array are required" });
      return;
    }

    if (messages.length === 0) {
      res.status(400).json({ error: "messages array must not be empty" });
      return;
    }

    // Input length validation
    if (systemPrompt.length > MAX_PROMPT_LENGTH) {
      res.status(400).json({ error: "Input too long" });
      return;
    }

    for (const msg of messages) {
      if (msg.content && msg.content.length > MAX_PROMPT_LENGTH) {
        res.status(400).json({ error: "Input too long" });
        return;
      }
    }

    try {
      const message = await getAnthropicClient().messages.create({
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: systemPrompt,
        messages: messages.map((m) => ({
          role: m.role,
          content: m.content,
        })),
      });

      const responseText =
        message.content[0].type === "text" ? message.content[0].text : "";

      res.status(200).json({ response: responseText });
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : String(err);
      functions.logger.error(
        "interpretPalmFollowup: Claude API error",
        errMsg
      );
      res.status(502).json({
        error: "Failed to get response from Claude",
        details: errMsg,
      });
    }
  });
