import 'package:flutter/material.dart';
import 'dart:async';
import 'settings.dart';
import 'welcome.dart';
import 'register.dart';
import 'login.dart';
import 'homepage.dart';
import 'package:timezone/data/latest.dart' as tz;

// Firebase dependencies
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main
  tz.initializeTimeZones();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const FirebaseGate(), // <-- Show FirebaseGate first
            '/welcome': (context) => const WelcomePage(),
            '/register': (context) => const RegisterPage(),
            '/login': (context) => const LoginPage(),
            '/settings': (context) => const AppSettingsScreen(),
            '/home': (context) => HomePage(),
          },
        );
      },
    );
  }
}

/// A widget that shows a loading indicator while Firebase initializes, then shows the real SplashScreen.
class FirebaseGate extends StatelessWidget {
  const FirebaseGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SplashScreen(logoAssetPath: 'images/logo.png');
        }
        // Show loading indicator while waiting for Firebase
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
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

    _dotTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 4) + 1;
        });
      }
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (mounted) {
        setState(() {
          _progressValue += 0.03;
          if (_progressValue >= 1.0) {
            _progressValue = 1.0;
            _progressTimer.cancel();

            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
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
              Image.asset('images/logo.png', height: 350, width: 850),
              const SizedBox(height: 40),
              Text(
                loadingText,
                style: const TextStyle(color: Colors.white70, fontSize: 21),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}