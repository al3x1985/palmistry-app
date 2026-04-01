import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/models/scan_result.dart';

/// HTTP client that calls the CV (Computer Vision) server to analyze
/// a palm image and return detected lines and shape data.
///
/// The base URL is injected at build time via --dart-define:
///   CV_SERVER_URL=http://192.168.1.x:8080
///
/// During Android emulator development the default reaches the host machine.
class CvApiClient {
  static const _defaultUrl = 'http://10.0.2.2:8080';

  final String _baseUrl;
  final http.Client _client;

  CvApiClient({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'CV_SERVER_URL',
              defaultValue: _defaultUrl,
            ),
        _client = client ?? http.Client();

  /// Sends the palm image (base64-encoded) and optional MediaPipe [landmarks]
  /// to the CV server `/analyze` endpoint.
  ///
  /// Returns a parsed [ScanResult] on success.
  /// Throws [CvApiException] on non-200 responses or network errors.
  Future<ScanResult> analyzePalm({
    required String imageBase64,
    required List<Map<String, double>> landmarks,
    required String hand,
  }) async {
    final body = jsonEncode({
      'image': imageBase64,
      'landmarks': landmarks,
      'hand': hand,
    });

    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      throw CvApiException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw CvApiException(
        'CV server returned ${response.statusCode}: ${response.body}',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ScanResult.fromJson(decoded);
    } catch (e) {
      throw CvApiException('Failed to parse CV response: $e');
    }
  }
}

/// Exception thrown by [CvApiClient] for API or network errors.
class CvApiException implements Exception {
  final String message;
  const CvApiException(this.message);

  @override
  String toString() => 'CvApiException: $message';
}
