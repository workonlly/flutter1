import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart' as globals;
import 'main.dart';
import 'debug_logger.dart';

void main() => runApp(const LoginApp());

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login",
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (email.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Check if user exists with GET request
      DebugLogger.info(
          'Attempting to connect to: http://127.0.0.1:8000/users/');

      final getUserResponse = await http.get(
        Uri.parse('http://127.0.0.1:8000/users/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      DebugLogger.log('GET response status: ${getUserResponse.statusCode}');
      DebugLogger.log('GET response body: ${getUserResponse.body}');

      if (getUserResponse.statusCode == 200) {
        final usersData = json.decode(getUserResponse.body);
        List users = usersData['users'] ?? [];

        // Check if user exists in the list
        bool userExists = users.any((user) => user['email'] == email.text);

        if (userExists) {
          // User exists - proceed with login
          DebugLogger.info('User exists, proceeding with login');
          _handleSuccessfulLogin();
        } else {
          // User doesn't exist - create new user with POST request
          DebugLogger.info('User does not exist, creating new user');
          await _createNewUser();
        }
      } else {
        // Failed to get users list, show error and fallback to creating user
        DebugLogger.error(
          'Failed to get users list, status: ${getUserResponse.statusCode}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Server error: ${getUserResponse.statusCode}. Attempting to create account...',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        await _createNewUser();
      }
    } catch (e) {
      // Network error or other exception
      DebugLogger.error('Exception in _login: $e');
      String errorMessage = 'Network error: ';

      if (e.toString().contains('TimeoutException')) {
        errorMessage +=
            'Connection timeout. Check if FastAPI server is running on http://127.0.0.1:8000';
      } else if (e.toString().contains('SocketException')) {
        errorMessage +=
            'Cannot connect to server. Is FastAPI running on port 8000?';
      } else if (e.toString().contains('ClientException')) {
        errorMessage +=
            'Network connection failed. Check your internet/server.';
      } else {
        errorMessage += e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewUser() async {
    try {
      // Step 2: Create new user with POST request to /register/ endpoint
      DebugLogger.info(
          'Attempting to register user at: http://127.0.0.1:8000/register/');
      DebugLogger.log('Email: ${email.text}');
      DebugLogger.log('Password length: ${passwordController.text.length}');

      final requestBody = {
        'email': email.text,
        'password': passwordController.text,
      };
      DebugLogger.log('Request body: ${json.encode(requestBody)}');

      final createUserResponse = await http
          .post(
            Uri.parse(
                'http://127.0.0.1:8000/register/'), // Changed to /register/
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      DebugLogger.log('POST response status: ${createUserResponse.statusCode}');
      DebugLogger.log('POST response body: ${createUserResponse.body}');

      if (createUserResponse.statusCode == 200) {
        final responseData = json.decode(createUserResponse.body);
        String status = responseData['status'] ?? '';
        String message = responseData['message'] ?? '';

        if (status == 'created') {
          // User created successfully
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully: $message'),
                backgroundColor: Colors.green,
              ),
            );
          }
          _handleSuccessfulLogin();
        } else if (status == 'exists') {
          // User already exists
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User exists: $message'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          _handleSuccessfulLogin();
        } else if (status == 'success') {
          // Login/creation successful
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful: $message'),
                backgroundColor: Colors.green,
              ),
            );
          }
          _handleSuccessfulLogin();
        } else if (status == 'error') {
          // Error from backend
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Backend error: $message'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Unknown status
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unknown response: $status - $message'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // HTTP error - provide detailed error information
        String errorBody = createUserResponse.body;
        DebugLogger.error(
          'HTTP Error Details: Status ${createUserResponse.statusCode}, Body: $errorBody',
        );

        // Parse error response for better user feedback
        String userMessage;
        try {
          final errorData = json.decode(errorBody);
          userMessage = errorData['detail'] ?? 'Unknown server error';
        } catch (e) {
          userMessage = 'Server error: $errorBody';
        }

        // Provide specific guidance for 401 errors
        if (createUserResponse.statusCode == 401) {
          userMessage =
              'Authentication failed: $userMessage\n\nThis usually means:\n• User exists with different password\n• Please check your credentials';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 7),
            ),
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Exception in _createNewUser: $e');
      String errorMessage = 'Error creating user: ';

      if (e.toString().contains('TimeoutException')) {
        errorMessage +=
            'Connection timeout. Check if FastAPI server is running on http://127.0.0.1:8000';
      } else if (e.toString().contains('SocketException')) {
        errorMessage += 'Cannot connect to server. Is FastAPI running?';
      } else if (e.toString().contains('ClientException')) {
        errorMessage += 'Network error. Check your connection.';
      } else {
        errorMessage += e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handleSuccessfulLogin() {
    // Set global variables when login is successful
    globals.globalpassword = passwordController.text;
    globals.globalEmail = email.text;
    globals.globalIsLoggedIn = true;

    // Navigate to main app, replacing login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  Future<void> _testServerConnection() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing server connection...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Test basic server connection
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      DebugLogger.log('Test connection status: ${response.statusCode}');
      DebugLogger.log('Test connection body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Server connection successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Server responded with status: ${response.statusCode}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Test connection error: $e');
      String errorMessage = '❌ Connection failed: ';

      if (e.toString().contains('TimeoutException')) {
        errorMessage += 'Timeout. Server not responding.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage += 'Cannot reach server. Is it running?';
      } else {
        errorMessage += e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Debug method to list all users
  Future<void> _debugListUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/debug/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      DebugLogger.log('Debug response: ${response.body}');

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          String message = 'Server Status: ${data['status']}\n';
          message += 'Users Count: ${data['users_count']}\n';
          if (data['sample_users'] != null) {
            message += 'Sample Users:\n';
            for (var user in data['sample_users']) {
              message += '• ${user['email']} (ID: ${user['id']})\n';
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 10),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debug failed: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Debug error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Debug method to clear current user data
  void _clearUserData() {
    email.clear();
    passwordController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data cleared'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Login",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.blue[400],
              letterSpacing: 1.3,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 3,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: email,
                style: GoogleFonts.roboto(),
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.person, color: Colors.blue[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  hintStyle: GoogleFonts.roboto(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 3,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                style: GoogleFonts.roboto(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  hintStyle: GoogleFonts.roboto(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Test server connection button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _testServerConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Test Server Connection',
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _debugListUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Debug: List Users',
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.blueAccent.withOpacity(0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Login',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
