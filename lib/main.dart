import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newfli/summary_view.dart';
import "login.dart";
import 'globals.dart' as globals;
import 'notification_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "summaryView",
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if global variables are empty or user is not logged in
    if (globals.globalEmail.isEmpty || !globals.globalIsLoggedIn) {
      return const LoginApp();
    } else {
      return const MainView();
    }
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool _notificationServiceRunning = false;
  bool _hasNotificationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    bool hasPermission = await NotificationService.hasNotificationPermission();
    setState(() {
      _hasNotificationPermission = hasPermission;
      _notificationServiceRunning = NotificationService.isListening;
    });
  }

  Future<void> _requestNotificationPermission() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Access Required'),
          content: const Text(
            'This app needs notification access to capture and analyze notifications. '
            'You will be redirected to settings to grant this permission.\n\n'
            'Please:\n'
            '1. Find this app in the list\n'
            '2. Enable "Notification access"\n'
            '3. Return to the app',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await NotificationService.requestNotificationPermission();
                await _checkNotificationStatus();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNotificationService() async {
    if (!_hasNotificationPermission) {
      await _requestNotificationPermission();
      return;
    }

    bool started = await NotificationService.startNotificationService();
    if (started) {
      setState(() {
        _notificationServiceRunning = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification service started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to start notification service'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopNotificationService() async {
    await NotificationService.stopNotificationService();
    setState(() {
      _notificationServiceRunning = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛑 Notification service stopped'),
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
        title: Text(
          "SummariZer",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              letterSpacing: 1.3,
              fontSize: 30,
              color: Colors.blue[400],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.blue[400], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Summaries of the day fuel the moto of progress ${globals.globalEmail} ',
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 1.1,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date summaries clickable container
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SummaryViewPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.summarize,
                                      color: Colors.blue[600],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Summary Reports",
                                      style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                          color: Colors.blue[800],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Click to view notification summaries by date",
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue[400],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Notification controls section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notifications, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Notification Listener',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _notificationServiceRunning
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _notificationServiceRunning ? 'ON' : 'OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!_hasNotificationPermission)
                          ElevatedButton.icon(
                            onPressed: _requestNotificationPermission,
                            icon: const Icon(Icons.security),
                            label: const Text('Grant Permission'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _notificationServiceRunning
                                      ? null
                                      : _startNotificationService,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Start'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _notificationServiceRunning
                                      ? _stopNotificationService
                                      : null,
                                  icon: const Icon(Icons.stop),
                                  label: const Text('Stop'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Builder(
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SecondPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Click Me',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              // Clear global variables to trigger automatic logout
                              globals.globalEmail = '';
                              globals.globalpassword = '';
                              globals.globalIsLoggedIn = false;

                              // Force rebuild to trigger AuthWrapper redirect
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyApp(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
