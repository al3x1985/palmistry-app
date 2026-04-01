# Flutter App Implementation Plan (Plan 2 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter Android app with camera scanner (MediaPipe), bezier line editor, rule engine, history, reference, and mystical dark UI — connecting to the CV Pipeline server for line detection and Firebase Cloud Function for AI interpretation.

**Architecture:** Flutter app with feature-based structure, BLoC state management, Drift/SQLite for local storage, Canvas API for bezier editing. MediaPipe provides real-time hand landmarks. CV server returns detected lines. Rule engine (local JSON) generates palmistry profile. Claude API generates narrative interpretation.

**Tech Stack:** Flutter 3.x, Dart 3.x, flutter_bloc, Drift (SQLite), GoRouter, get_it, google_mlkit_commons/mediapipe, Canvas/CustomPainter, Firebase Analytics/Crashlytics

---

## Task 1: Flutter Project Scaffolding

**Files:**
- Create: `palmistry_app/pubspec.yaml`
- Create: `palmistry_app/lib/main.dart`
- Create: `palmistry_app/analysis_options.yaml`
- Create: `palmistry_app/l10n.yaml`
- Create: `palmistry_app/lib/l10n/app_ru.arb`

- [ ] **Step 1: Create Flutter project**

```bash
cd /Users/macbook/Development/palmistry-app
flutter create palmistry_app --org com.palmistryapp --platforms android
```

- [ ] **Step 2: Replace pubspec.yaml**

Key dependencies: flutter_bloc, equatable, go_router, drift, sqlite3_flutter_libs, path_provider, get_it, http, uuid, intl, shared_preferences, camera, image_picker, firebase_core, firebase_analytics, firebase_crashlytics.

Dev: flutter_lints, drift_dev, build_runner, bloc_test, mocktail.

Assets: `assets/rules/`, `assets/content/`.

- [ ] **Step 3: Create l10n files** (Russian only)

- [ ] **Step 4: Stub main.dart, flutter pub get, verify**

- [ ] **Step 5: Commit**

---

## Task 2: Core Models & Enums

**Files:**
- Create: `lib/core/models/enums.dart` — Hand (left/right), PalmShape, LineType, ScanStatus, LineDepth, LineCurvature, MessageRole
- Create: `lib/core/models/palm_line.dart` — PalmLineData (type, bezier points, characteristics)
- Create: `lib/core/models/scan_result.dart` — ScanResult (palm shape, lines, finger proportions)
- Create: `lib/core/models/interpretation.dart` — PalmInterpretation (overview, personality, relationships, career, health, disclaimer?)
- Test: `test/core/models/interpretation_test.dart`

---

## Task 3: Drift Database

**Files:**
- Create: `lib/data/local/tables/palm_scans.dart`
- Create: `lib/data/local/tables/palm_lines.dart`
- Create: `lib/data/local/tables/line_readings.dart`
- Create: `lib/data/local/tables/scan_messages.dart`
- Create: `lib/data/local/database.dart`
- Create: `lib/data/local/daos/scan_dao.dart`
- Create: `lib/data/local/daos/message_dao.dart`
- Test: `test/data/local/daos/scan_dao_test.dart`

Tables match the spec: PalmScan, PalmLine, LineReading, ScanMessage.

---

## Task 4: API Clients

**Files:**
- Create: `lib/data/remote/cv_api_client.dart` — POST /analyze to CV Pipeline server
- Create: `lib/data/remote/claude_api_client.dart` — POST to Cloud Function (same as tarot app)

CV client sends base64 image + landmarks JSON, receives PalmAnalysisResponse.

---

## Task 5: Rule Engine

**Files:**
- Create: `lib/core/services/rule_engine.dart`
- Create: `assets/rules/heart_line.json` (~15 rules)
- Create: `assets/rules/head_line.json` (~12 rules)
- Create: `assets/rules/life_line.json` (~12 rules)
- Create: `assets/rules/fate_line.json` (~10 rules)
- Create: `assets/rules/palm_shape.json` (~10 rules)
- Create: `assets/rules/fingers.json` (~6 rules)
- Test: `test/core/services/rule_engine_test.dart`

Rule engine loads JSON rules, evaluates conditions against line data, returns list of LineReading (trait, category, confidence, description).

---

## Task 6: DI, Theme, Router, App Shell

**Files:**
- Create: `lib/app/di.dart`
- Create: `lib/app/theme.dart` — mystical minimalism (same as tarot: 0xFF0F0F1A bg, purple accents)
- Create: `lib/app/router.dart` — 4 tabs: Scanner, History, Reference, Settings
- Create: `lib/app/app.dart`
- Modify: `lib/main.dart`
- Create stub screens for all features

---

## Task 7: Scanner Feature (Camera + MediaPipe)

**Files:**
- Create: `lib/features/scanner/bloc/scanner_bloc.dart`, events, states
- Create: `lib/features/scanner/ui/scanner_screen.dart` — camera preview with MediaPipe overlay
- Create: `lib/features/scanner/ui/processing_screen.dart` — progress animation

Scanner flow: camera → MediaPipe landmarks in realtime → user taps "Scan" → capture photo → send to CV server → navigate to editor.

NOTE: MediaPipe Flutter integration uses `google_mlkit_hand_landmark_detection` or `mediapipe_hands` package. Check what's available and use the most stable option. If no good Flutter package exists, use `camera` package for capture and send raw image to server (server can run MediaPipe too).

---

## Task 8: Bezier Editor Feature

**Files:**
- Create: `lib/features/editor/bloc/editor_bloc.dart`, events, states
- Create: `lib/features/editor/ui/editor_screen.dart` — photo with bezier overlay
- Create: `lib/features/editor/ui/line_painter.dart` — CustomPainter for bezier curves + control points
- Create: `lib/features/editor/ui/line_list_panel.dart` — list of detected lines with delete/add

Editor: shows photo with colored bezier lines (heart=red, head=blue, life=green, fate=yellow). Control points draggable. Can delete line, add new line (pick type → tap points).

---

## Task 9: Reading Feature (Rule Engine + Claude)

**Files:**
- Create: `lib/features/reading/bloc/reading_bloc.dart`, events, states
- Create: `lib/features/reading/services/prompt_builder.dart`
- Create: `lib/features/reading/ui/reading_result_screen.dart`
- Create: `lib/features/reading/ui/follow_up_chat.dart`
- Test: `test/features/reading/services/prompt_builder_test.dart`

After editor → run rule engine → show traits → call Claude for narrative → display result with sections (overview, personality, relationships, career, health).

---

## Task 10: History Feature

**Files:**
- Create: `lib/features/history/bloc/history_bloc.dart`, events, states
- Create: `lib/features/history/ui/history_screen.dart`
- Test: `test/features/history/bloc/history_bloc_test.dart`

---

## Task 11: Reference Feature (Palmistry Encyclopedia)

**Files:**
- Create: `lib/features/reference/ui/reference_screen.dart`
- Create: `lib/features/reference/ui/line_detail_screen.dart`
- Create: `assets/content/reference.json` — palmistry reference content in Russian

---

## Task 12: Settings + Onboarding

**Files:**
- Create: `lib/features/settings/ui/settings_screen.dart`
- Create: `lib/features/settings/ui/about_screen.dart`
- Create: `lib/features/onboarding/ui/onboarding_screen.dart`

Onboarding: 3 screens about palmistry (like tarot app). About: full text about palmistry, privacy disclaimer.

---

## Task 13: Analytics + CI

**Files:**
- Create: `lib/core/services/analytics_service.dart`
- Create: `.github/workflows/flutter-ci.yml`

Analytics events: scan_started, scan_completed, lines_edited, interpretation_generated, followup_asked, scan_saved.
