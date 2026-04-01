import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Analytics.
///
/// All log calls are wrapped in try-catch so that an unconfigured Firebase
/// project (e.g. during development or CI) never crashes the app.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  // ---------------------------------------------------------------------------
  // Core events
  // ---------------------------------------------------------------------------

  /// Called when the user initiates a palm scan.
  Future<void> logScanStarted({required String hand}) async {
    await _safeLog(
      'scan_started',
      parameters: {'hand': hand},
    );
  }

  /// Called when CV analysis returns successfully.
  Future<void> logScanCompleted({
    required int scanId,
    required String palmShape,
    required int lineCount,
  }) async {
    await _safeLog(
      'scan_completed',
      parameters: {
        'scan_id': scanId,
        'palm_shape': palmShape,
        'line_count': lineCount,
      },
    );
  }

  /// Called when the user saves edits in the bezier editor.
  Future<void> logLinesEdited({
    required int scanId,
    required int lineCount,
  }) async {
    await _safeLog(
      'lines_edited',
      parameters: {'scan_id': scanId, 'line_count': lineCount},
    );
  }

  /// Called when AI interpretation is generated.
  Future<void> logInterpretationGenerated({required int scanId}) async {
    await _safeLog(
      'interpretation_generated',
      parameters: {'scan_id': scanId},
    );
  }

  /// Called when the user sends a follow-up chat message.
  Future<void> logFollowupAsked({required int scanId}) async {
    await _safeLog(
      'followup_asked',
      parameters: {'scan_id': scanId},
    );
  }

  /// Called when the user saves / confirms a scan result.
  Future<void> logScanSaved({required int scanId}) async {
    await _safeLog(
      'scan_saved',
      parameters: {'scan_id': scanId},
    );
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  Future<void> _safeLog(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Analytics] Failed to log "$name": $e');
      }
    }
  }
}
