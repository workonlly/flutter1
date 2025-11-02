class DebugLogger {
  static final bool _isDebugMode = true; // Set to false in production
  
  static void log(String message) {
    if (_isDebugMode) {
      // In production, you could use a proper logging framework
      // ignore: avoid_print
      print(message);
    }
  }
  
  static void error(String message) {
    if (_isDebugMode) {
      // ignore: avoid_print
      print('ERROR: $message');
    }
  }
  
  static void info(String message) {
    if (_isDebugMode) {
      // ignore: avoid_print
      print('INFO: $message');
    }
  }
}