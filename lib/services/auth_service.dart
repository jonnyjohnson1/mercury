import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mercury/services/firebase_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      // print('User state changed: $user');
    });
  }

  Future<firebase_auth.User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  String convertToE164(String phoneNumber, {String countryCode = '+1'}) {
    // Remove any non-digit characters
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the number is 10 digits long (after cleaning)
    if (cleanedNumber.length == 10) {
      // Return the number in E.164 format with the country code
      return '$countryCode$cleanedNumber';
    } else {
      throw FormatException('Invalid phone number format');
    }
  }

  Future<void> signInWithPhoneNumber(
      String phoneNumber, Function(String verificationId) codeSent,
      {Function(firebase_auth.FirebaseAuthException)? verificationFailed,
      Duration timeout = const Duration(seconds: 60)}) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Sign the user in with the provided credential
          try {
            await _auth.signInWithCredential(credential);
            // Optionally, you can handle further actions after sign-in
          } catch (e) {
            print("Error during automatic verification: $e");
          }
        },
        verificationFailed: verificationFailed ??
            (firebase_auth.FirebaseAuthException e) {
              print(e.message);
            },
        codeSent: (String verificationId, int? resendToken) {
          // Pass the verification ID back to the UI so the user can input the SMS code
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timed out
          print(
              "Auto retrieval timed out for verification ID: $verificationId");
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<firebase_auth.User?> verifySMSCode(
      String verificationId, String smsCode) async {
    try {
      firebase_auth.PhoneAuthCredential credential =
          firebase_auth.PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);
      firebase_auth.UserCredential result =
          await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<firebase_auth.User?> signInAnonymously() async {
    try {
      print("signin anonymously");
      firebase_auth.UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<firebase_auth.User?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      firebase_auth.UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // write user information to users
      // user name, profile information
      String userId = result.user!.uid;
      print("creating user :: $userId");
      await FirebaseService().createUser(userId, name);

      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      firebase_auth.User? user = _auth.currentUser;
      // This is done this way in order to create an anonymous user
      if (user == null) {
        // If no user is logged in, sign in anonymously
        firebase_auth.UserCredential result = await _auth.signInAnonymously();
        user = result.user;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Create user object based on FirebaseUser
  firebase_auth.User? _userFromFirebaseUser(firebase_auth.User? user) {
    return user != null ? user : null;
  }

  // Auto login check
  Future<firebase_auth.User?> autoLogin() async {
    try {
      firebase_auth.User? user = _auth.currentUser;
      if (user == null) {
        // If no user is logged in, sign in anonymously
        firebase_auth.UserCredential result = await _auth.signInAnonymously();
        user = result.user;
      }
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Auth change user stream
  Stream<firebase_auth.User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }
}
