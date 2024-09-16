import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mercury/screens/phone_input_field.dart';
import 'package:mercury/screens/verification_input_field.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String verificationId;

  VerificationCodeScreen({required this.verificationId});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _verifyCode(String smsCode) async {
    if (smsCode.isNotEmpty) {
      print(widget.verificationId);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      try {
        print("signing in");
        print(credential);
        await _auth.signInWithCredential(credential);
        print("going home");
        context.go('/home'); // Use go_router to navigate to /home
      } catch (e) {
        print('Failed to verify code: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            SMSVerificationInputField(
              onSubmit: (String smsCode) {
                _verifyCode(smsCode);
              },
            )
          ],
        ),
      ),
    );
  }
}
