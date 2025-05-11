import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome.dart'; // Import the WelcomePage
import 'register.dart'; // Import the RegisterPage
import 'login.dart'; // Import the LoginPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => SplashScreen(logoAssetPath: 'images/logo.png'), // SplashScreen is now the initial route
        '/welcome': (context) => const WelcomePage(), // Add WelcomePage route
        '/register': (context) => const RegisterPage(), // Add RegisterPage route
        '/login': (context) => const LoginPage(), // Add LoginPage route
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final String logoAssetPath;

  const SplashScreen({super.key, required this.logoAssetPath});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _dotCount = 1;
  late Timer _dotTimer;
  late Timer _progressTimer;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Animate loading dots
    _dotTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 4) + 1;
        });
      }
    });

    // Slower progress bar
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (mounted) {
        setState(() {
          _progressValue += 0.03;
          if (_progressValue >= 1.0) {
            _progressValue = 1.0;
            _progressTimer.cancel();

            // Navigate to WelcomePage after progress completes
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // Apply a fade (dissolve) transition
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400), // Smooth transition duration
                  ),
                );
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _dotTimer.cancel();
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingText = 'Loading${'.' * _dotCount}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display the logo with height
              Image.asset('images/logo.png', height: 350, width: 850),
              const SizedBox(height: 40),
              // Display the loading text
              Text(
                loadingText,
                style: const TextStyle(color: Colors.white70, fontSize: 21),
              ),
              const SizedBox(height: 20),
              // Display the progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 40), // Space below the progress bar
            ],
          ),
        ),
      ),
    );
  }
}