import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// HTTP client that calls Firebase Cloud Functions which proxy requests
/// to the Anthropic Claude API for palm interpretation and follow-up chat.
///
/// The base URLs are injected at build time via --dart-define:
///   CLOUD_FUNCTION_URL=https://<region>-<project>.cloudfunctions.net/interpretPalm
///   CLOUD_FUNCTION_FOLLOWUP_URL=https://<region>-<project>.cloudfunctions.net/interpretPalmFollowup
///
/// During local development, the Android emulator default (10.0.2.2) is used
/// to reach the Firebase emulator running on the host machine.
class ClaudeApiClient {
  static const _defaultUrl =
      'http://10.0.2.2:5001/palmistry-app/us-central1/interpretPalm';

  static const _defaultFollowUpUrl =
      'http://10.0.2.2:5001/palmistry-app/us-central1/interpretPalmFollowup';

  final String _baseUrl;
  final String _followUpUrl;
  final http.Client _client;

  ClaudeApiClient({
    http.Client? client,
    String? baseUrl,
    String? followUpUrl,
  })  : _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'CLOUD_FUNCTION_URL',
              defaultValue: _defaultUrl,
            ),
        _followUpUrl = followUpUrl ??
            const String.fromEnvironment(
              'CLOUD_FUNCTION_FOLLOWUP_URL',
              defaultValue: _defaultFollowUpUrl,
            ),
        _client = client ?? http.Client() {
    if (kReleaseMode) {
      if (_baseUrl == _defaultUrl) {
        throw StateError(
          'CLOUD_FUNCTION_URL must be set for release builds. '
          'Use: flutter build apk --dart-define=CLOUD_FUNCTION_URL=https://...',
        );
      }
      if (_followUpUrl == _defaultFollowUpUrl) {
        throw StateError(
          'CLOUD_FUNCTION_FOLLOWUP_URL must be set for release builds. '
          'Use: flutter build apk --dart-define=CLOUD_FUNCTION_FOLLOWUP_URL=https://...',
        );
      }
    }
  }

  /// Returns true if a real [CLOUD_FUNCTION_URL] was provided at build time.
  static bool get isConfigured {
    const url =
        String.fromEnvironment('CLOUD_FUNCTION_URL', defaultValue: '');
    return url.isNotEmpty;
  }

  /// Sends [systemPrompt] and [userPrompt] to the Cloud Function and returns
  /// the JSON string that Claude produced (to be parsed as [PalmInterpretation]).
  ///
  /// Throws [ClaudeApiException] on non-200 responses or network errors.
  Future<String> getInterpretation({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final body = jsonEncode({
      'systemPrompt': systemPrompt,
      'userPrompt': userPrompt,
    });

    final response = await _post(_baseUrl, body);
    final decoded = _decodeResponse(response);
    return decoded['interpretation'] as String;
  }

  /// Sends a follow-up message in an ongoing conversation.
  ///
  /// [messages] is an ordered list of `{"role": "user"|"assistant", "content": "..."}` maps.
  Future<String> getFollowUp({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async {
    final body = jsonEncode({
      'systemPrompt': systemPrompt,
      'messages': messages,
    });

    final response = await _post(_followUpUrl, body);
    final decoded = _decodeResponse(response);
    return decoded['response'] as String;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<http.Response> _post(String url, String body) async {
    try {
      return await _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': const String.fromEnvironment(
            'APP_API_SECRET',
            defaultValue: '',
          ),
        },
        body: body,
      );
    } catch (e) {
      throw ClaudeApiException('Network error: $e');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ClaudeApiException(
        'Cloud Function returned ${response.statusCode}: ${response.body}',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ClaudeApiException('Failed to parse response: ${response.body}');
    }
  }
}

/// Exception thrown by [ClaudeApiClient] for API or network errors.
class ClaudeApiException implements Exception {
  final String message;
  const ClaudeApiException(this.message);

  @override
  String toString() => 'ClaudeApiException: $message';
}
