import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const VerifyEmailPage({
    required this.email,
    required this.password,
    required this.username,
    super.key,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _checking = false;
  String? _error;
  bool _firestoreWritten = false;

  Future<void> _onCheckVerified() async {
    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      await cred.user!.reload();

      final user = FirebaseAuth.instance.currentUser;
      final isVerified = cred.user!.emailVerified || (user != null && user.emailVerified);

      if (isVerified) {
        if (!_firestoreWritten) {
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'username': widget.username,
            'email': widget.email,
            'createdAt': DateTime.now(),
          });
          _firestoreWritten = true;
        }
        if (!mounted) return;
        // Change here: navigate to /login instead of /home
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _checking = false;
          _error = "Email not verified yet. Please click the link in your email.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _checking = false;
        _error = e.message ?? "Error occurred";
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _checking = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      await cred.user!.sendEmailVerification();
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent!')),
      );
    } catch (e) {
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            color: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _checking
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 20),
                  Text("Checking...", style: TextStyle(color: Colors.white)),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    "A verification link was sent to:",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onCheckVerified,
                    child: const Text("I've verified my email"),
                  ),
                  TextButton(
                    onPressed: _resendEmail,
                    child: const Text("Resend Email", style: TextStyle(color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}