import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mercury/screens/phone_input_field.dart';
import 'package:mercury/services/kc_auth.dart';
// import 'package:mercury/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:openid_client/openid_client_browser.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _auth = FirebaseAuth.instance;
  void _signInWithPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      // String e16Phone = AuthService().convertToE164(phoneNumber);

      // TODO I think this is only available on mobile devices.
      // WEB requires this method, and a recaptcha flow signInWithPhoneNumber
      // await _auth.verifyPhoneNumber(
      //   phoneNumber: e16Phone,
      //   timeout: const Duration(seconds: 60),
      //   verificationCompleted: (PhoneAuthCredential credential) async {
      //     // Auto sign in
      //     await _auth.signInWithCredential(credential);
      //   },
      //   verificationFailed: (FirebaseAuthException e) {
      //     print('Verification failed: ${e.message}');
      //   },
      //   codeSent: (String verificationId, int? resendToken) {
      //     // print("verid sent to path: $verificationId");
      //     context.go('/verify', extra: {'verificationId': verificationId});
      //   },
      //   codeAutoRetrievalTimeout: (String verificationId) {
      //     print('Auto-retrieval timeout: $verificationId');
      //   },
      // );
    }
  }

  createKCUser(String phoneNumber) async {
    // create the client
    final authService = AuthService();
    // Fetch the auth token
    final token = await authService.getAuthToken();
    if (token != null) {
      print("Token fetched successfully");

      // Create a new user
      final success = await authService.createUser();
      if (success) {
        print("User created successfully!");
      } else {
        print("Failed to create user.");
      }
    } else {
      print("Failed to fetch the token.");
    }
  }

  // Using OpenID
  authenticate(Uri uri, String clientId, List<String> scopes) async {
    var issuer = await Issuer.discover(uri);
    var client = Client(issuer, clientId);

    debugPrint("\t[ keycloak :: created the client ]");
    // create an authenticator

    var authenticator = Authenticator(client, scopes: scopes);
    debugPrint("\t[ keycloak :: created an authenticator ]");
    print(authenticator.flow.authenticationUri);
    print(authenticator.flow.client.clientId);
    print(authenticator.flow.client.httpClient);
    print(authenticator.flow.client.issuer.metadata);
    print(authenticator.flow.scopes);
    print(authenticator.flow.state);
    print(authenticator.flow.type);
    // get the credential
    var c = await authenticator.credential;
    debugPrint("\t[ keycloak :: got the credential c=$c ]");

    if (c == null) {
      // starts the authentication
      debugPrint("\t[ keycloak :: authorizing... ]");
      authenticator.authorize(); // this will redirect the browser
      debugPrint("\t[ keycloak :: authenticated ]");
    } else {
      // return the user info
      return await c.getUserInfo();
    }
  }

  void _signInWithKeyCloak(String phoneNumber) async {
    debugPrint("[ keycloak auth flow :: beginning]");
    createKCUser(phoneNumber);

    // authenticate(Uri.parse('http://localhost:8080/realms/master'), 'test-mfa', [
    //   "openid",
    //   "profile",
    //   "address",
    //   "offline_access",
    //   "email",
    //   "web-origins",
    //   "phone",
    //   "microprofile-jwt",
    //   "roles",
    //   "acr"
    // ]);
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
            TextButton(
                onPressed: () {
                  // initializeOpenIDClient();
                },
                child: const Text("Login")),
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
                _signInWithKeyCloak(submittedPhoneNumber);
                // _signInWithPhoneNumber(submittedPhoneNumber);
              },
            )
          ],
        ),
      ),
    );
  }
}
