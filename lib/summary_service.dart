import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'debug_logger.dart';

class SummaryService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Model for summary data
  static Map<String, dynamic> _formatSummaryData(Map<String, dynamic> rawData) {
    return {
      'id': rawData['id'] ?? 0,
      'date': rawData['date'] ?? '',
      'summary': rawData['summary'] ?? 'No summary available',
      'notification_count': rawData['notification_count'] ?? 0,
      'created_at': rawData['created_at'] ?? '',
    };
  }

  // Get summaries for the logged-in user
  static Future<Map<String, dynamic>> getSummaries({
    String? startDate,
    String? endDate,
    String? specificDate,
  }) async {
    try {
      String userEmail = globals.globalEmail;
      if (userEmail.isEmpty) {
        throw Exception('User not logged in');
      }

      // Build query parameters
      Map<String, String> queryParams = {};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (specificDate != null) queryParams['date'] = specificDate;

      // Build URL with query parameters
      String url = '$baseUrl/summaries/$userEmail';
      if (queryParams.isNotEmpty) {
        String queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }

      DebugLogger.log('Fetching summaries from: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      DebugLogger.log('Summary response status: ${response.statusCode}');
      DebugLogger.log('Summary response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Format summaries data
        List<Map<String, dynamic>> formattedSummaries = [];
        if (data['summaries'] != null) {
          for (var summary in data['summaries']) {
            formattedSummaries.add(_formatSummaryData(summary));
          }
        }

        return {
          'success': true,
          'user_email': data['user_email'] ?? userEmail,
          'total_summaries': data['total_summaries'] ?? 0,
          'summaries': formattedSummaries,
          'date_range': data['date_range'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': 'Server returned status ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      DebugLogger.error('Error fetching summaries: $e');
      return {
        'success': false,
        'error': 'Network error',
        'message': e.toString(),
      };
    }
  }

  // Get summaries for today
  static Future<Map<String, dynamic>> getTodaySummaries() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    return await getSummaries(specificDate: today);
  }

  // Get summaries for a specific date
  static Future<Map<String, dynamic>> getSummariesForDate(String date) async {
    return await getSummaries(specificDate: date);
  }

  // Get summaries for a date range
  static Future<Map<String, dynamic>> getSummariesForDateRange(
    String startDate,
    String endDate,
  ) async {
    return await getSummaries(startDate: startDate, endDate: endDate);
  }

  // Get recent summaries (last 7 days)
  static Future<Map<String, dynamic>> getRecentSummaries() async {
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    String startDate = sevenDaysAgo.toIso8601String().split('T')[0];
    String endDate = now.toIso8601String().split('T')[0];

    return await getSummariesForDateRange(startDate, endDate);
  }

  // Format date for display
  static String formatDate(String isoDate) {
    try {
      DateTime date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  // Format date for API (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }
}
