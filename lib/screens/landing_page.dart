import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mercury/screens/phone_input_field.dart';
import 'package:mercury/services/auth_service.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _auth = FirebaseAuth.instance;
  void _signInWithPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      String e16Phone = AuthService().convertToE164(phoneNumber);

      await _auth.verifyPhoneNumber(
        phoneNumber: e16Phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto sign in
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // print("verid sent to path: $verificationId");
          context.go('/verify', extra: {'verificationId': verificationId});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto-retrieval timeout: $verificationId');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);

    if (user != null) {
      // User is signed in, navigate to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
      return Container(); // Return an empty container while redirecting
    }
    return Scaffold(
      backgroundColor: const Color(0xFF343232),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(243, 255, 255, 255),
                borderRadius: BorderRadius.circular(30.0),
              ),
              width: 128,
              height: 128,
            ),
            const SizedBox(height: 48),
            PhoneInputField(
              onSubmit: (String submittedPhoneNumber) {
                _signInWithPhoneNumber(submittedPhoneNumber);
              },
            )
          ],
        ),
      ),
    );
  }
}
