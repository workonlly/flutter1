import 'dart:convert';
// import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'debug_logger.dart';

class NotificationService {
  static bool _isListening = false;
  static bool _hasPermission = false;

  // Check if notification access permission is granted
  static Future<bool> hasNotificationPermission() async {
    // return await NotificationsListener.hasPermission ?? false;
    return false; // Temporarily disabled
  }

  // Request notification access permission (opens settings)
  static Future<bool> requestNotificationPermission() async {
    // await NotificationsListener.openPermissionSettings();
    // Check permission after user potentially grants it
    await Future.delayed(const Duration(milliseconds: 500));
    _hasPermission = await hasNotificationPermission();
    return _hasPermission;
  }

  // Initialize notification listener
  static Future<void> initializeNotificationListener() async {
    _hasPermission = await hasNotificationPermission();

    if (_hasPermission && !_isListening) {
      _startListening();
    }
  }

  // Start listening for notifications (mock implementation)
  static void _startListening() {
    /*
    NotificationsListener.receivePort?.listen((evt) async {
      await _handleNotification(evt);
    });
    */

    _isListening = true;
    DebugLogger.info("Notification listener started (mock mode)");
  }

  // Handle incoming notifications (mock implementation)
  static Future<void> _handleNotification(dynamic event) async {
    DebugLogger.log("=== Mock Notification Received ===");
    DebugLogger.log("Package Name: mock.package");
    DebugLogger.log("Title: Mock Notification");
    DebugLogger.log("Text: This is a mock notification");
    DebugLogger.log("User Email: ${globals.globalEmail}");
    DebugLogger.log("Timestamp: ${DateTime.now()}");

    // Prepare notification data with user email
    Map<String, dynamic> notificationData = {
      'package_name': 'mock.package',
      'title': 'Mock Notification',
      'content': 'This is a mock notification for testing',
      'timestamp': DateTime.now().toIso8601String(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'raw_text': 'Mock notification text',
      'user_email': globals.globalEmail, // Include the logged-in user's email
    };

    // Send to backend
    await _sendNotificationToBackend(notificationData);
  }

  // Send notification data to FastAPI backend
  static Future<void> _sendNotificationToBackend(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:8000/notifications/'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        DebugLogger.log("✅ Notification sent to backend successfully");
      } else {
        DebugLogger.error("❌ Failed to send notification: ${response.statusCode}");
        DebugLogger.error("Response: ${response.body}");
      }
    } catch (e) {
      DebugLogger.error("❌ Error sending notification to backend: $e");
    }
  }

  // Start notification service (mock implementation)
  static Future<bool> startNotificationService() async {
    try {
      // bool? started = await NotificationsListener.startService();
      bool started = true; // Mock success
      if (started == true) {
        await initializeNotificationListener();
        DebugLogger.info("Notification service started successfully (mock mode)");
        return true;
      } else {
        DebugLogger.error("Failed to start notification service");
        return false;
      }
    } catch (e) {
      DebugLogger.error("Error starting notification service: $e");
      return false;
    }
  }

  // Stop notification service (mock implementation)
  static Future<void> stopNotificationService() async {
    // await NotificationsListener.stopService();
    _isListening = false;
    DebugLogger.info("Notification service stopped (mock mode)");
  }

  // Get current listening status
  static bool get isListening => _isListening;

  // Simulate a test notification (for testing purposes)
  static Future<void> sendTestNotification() async {
    if (globals.globalEmail.isNotEmpty) {
      await _handleNotification('test_event');
    }
  }
  static bool get hasPermission => _hasPermission;
}
