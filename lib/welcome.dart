import 'package:flutter/material.dart';
import 'register.dart'; // Import the RegisterPage
import 'login.dart'; // Import the LoginPage

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Students Image
            Image.asset(
              'images/students.png', // Replace with your students image path
              height: 300,
            ),
            // Tagline
            Text(
              'SIMPLIFYING STUDENT LIFE\nONE TAP AT A TIME!!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            // Login Button
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Smooth transition to the LoginPage
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Slide in from the right
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var slideAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: slideAnimation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400), // Smooth and quick
                    ),
                  );
                },
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // OR Divider
            const Text(
              '--------------OR--------------',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            // Register Button
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Smooth transition to the RegisterPage
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Slide in from the right
                        const end = Offset.zero; // Ends at the current position
                        const curve = Curves.easeIn;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var slideAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: slideAnimation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400), // Smooth and quick
                    ),
                  );
                },
                child: const Text(
                  'REGISTER',
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
    );
  }
}