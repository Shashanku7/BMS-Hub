import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'reset_password.dart'; // Import the Reset Password Page

class ResetCodePage extends StatefulWidget {
  const ResetCodePage({super.key});

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  final List<TextEditingController> _codeControllers =
  List.generate(6, (index) => TextEditingController());
  final TextEditingController _emailController = TextEditingController();
  bool _isCodeVisible = false; // State to toggle visibility of code input boxes
  bool _isVerifying = false; // State for showing verification animation
  String? _errorMessage; // Error message for invalid input

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email address";
      });
      return;
    }

    setState(() {
      _errorMessage = null; // Clear error message
      _isCodeVisible = true; // Show the code input boxes
    });

    _showSmallPopup("Code sent to $email@bmsce.ac.in successfully!");
  }

  void _verifyCode() {
    final enteredCode =
    _codeControllers.map((controller) => controller.text).join(); // Combine all digits

    if (enteredCode.length != 6 || enteredCode.contains(RegExp(r'\D'))) {
      setState(() {
        _errorMessage = "Enter all 6 numeric digits";
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null; // Clear error message
    });

    // Simulate a brief delay for verification
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
      });

      // Navigate to Reset Password Page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const ResetPasswordPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  void _showSmallPopup(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry into the overlay
    overlay.insert(overlayEntry);

    // Remove the overlay entry after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration Image
                Image.asset(
                  'images/verification_code.png', // Replace with your image path
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  "Verification Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your email to receive the verification code.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Email Input Field with Partition
                if (!_isCodeVisible)
                  Row(
                    children: [
                      // Username Field
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white12,
                            hintText: "Enter your username",
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      // Partition Line
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "@",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      // Fixed Domain
                      const Text(
                        "bmsce.ac.in",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                if (_errorMessage != null && !_isCodeVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                // Send Code Button
                if (!_isCodeVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rectangular shape
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Send Code",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                // Verification Code Boxes
                if (_isCodeVisible)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _codeControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(color: Colors.white, fontSize: 24),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.white12,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // Allow only numeric input
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus(); // Move to the next box
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus(); // Move to the previous box
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      const SizedBox(height: 20),
                      // Confirm Button for Code
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isVerifying
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // Resend Code
                if (_isCodeVisible)
                  GestureDetector(
                    onTap: () {
                      _showSmallPopup("Reset code resent successfully!"); // Show small popup
                    },
                    child: const Text(
                      'Did not receive the code?\nSend Again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}