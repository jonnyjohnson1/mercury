import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:mercury/screens/home_screen.dart';
import 'package:mercury/screens/landing_page.dart';
import 'package:mercury/screens/verification_code_screen.dart';
import 'package:mercury/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyD1qpx8xnA9PhnD7kDOqTrJ6OOMtv_dGoE",
        authDomain: "mercury-messenger-d9f19.firebaseapp.com",
        projectId: "mercury-messenger-d9f19",
        storageBucket: "mercury-messenger-d9f19.appspot.com",
        messagingSenderId: "858692056572",
        appId: "1:858692056572:web:cf9d91a093e1fc179cae79"
        // measurementId: "G-C82ZVPEBV7"
        ),
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GoRouter get _router => GoRouter(
        navigatorKey: navigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LandingPage(),
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const LandingPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child; // No animation
              },
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => HomeScreen(),
            pageBuilder: (context, state) => CustomTransitionPage(
              child: HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child; // No animation
              },
            ),
          ),
          GoRoute(
            path: '/verify',
            builder: (context, state) {
              final verificationId = state.extra as Map<String, String>? ?? {};
              return VerificationCodeScreen(
                  verificationId: verificationId['verificationId'] ?? '');
            },
          ),
          // GoRoute(
          //     path: '/login',
          //     builder: (context, state) {
          //       // print("*" * 42);
          //       // print(state.pathParameters['create']);
          //       return LoginScreen(key: const Key("login"), isLogin: true);
          //     },
          //     pageBuilder: (context, state) {
          //       // print("*" * 42);
          //       // print(state.pathParameters['create']);
          //       return CustomTransitionPage(
          //         child: LoginScreen(key: const Key("login"), isLogin: true),
          //         transitionsBuilder:
          //             (context, animation, secondaryAnimation, child) {
          //           return child; // No animation
          //         },
          //       );
          //     }),
          // GoRoute(
          //   path: '/signup',
          //   builder: (context, state) =>
          //       LoginScreen(key: const Key("signup"), isLogin: false),
          //   pageBuilder: (context, state) => CustomTransitionPage(
          //     child: LoginScreen(key: const Key("signup"), isLogin: false),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       return child; // No animation
          //     },
          //   ),
          // ),
          // GoRoute(
          //   path: '/account',
          //   builder: (context, state) => UserAccount(),
          //   pageBuilder: (context, state) => CustomTransitionPage(
          //     child: UserAccount(),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       return child; // No animation
          //     },
          //   ),
          // ),
          // GoRoute(
          //   path: '/submit-form',
          //   builder: (context, state) => SaveSubmitForm(),
          //   pageBuilder: (context, state) => CustomTransitionPage(
          //     child: SaveSubmitForm(),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       return child; // No animation
          //     },
          //   ),
          // ),
          // GoRoute(
          //   path: '/write',
          //   builder: (context, state) => WriteScreen(),
          //   pageBuilder: (context, state) => CustomTransitionPage(
          //     child: WriteScreen(),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       return child; // No animation
          //     },
          //   ),
          // ),
        ],
        debugLogDiagnostics: true,
      );

  // ValueNotifier<UserAccountSettings?> userAccountSettings = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
        value: AuthService().user,
        initialData: null,
        child: MaterialApp.router(
            title: 'Mercury',
            debugShowCheckedModeBanner: false,
            builder: FToastBuilder(),
            theme: ThemeData(
              useMaterial3: true,
              textSelectionTheme: const TextSelectionThemeData(
                selectionColor: Color.fromARGB(255, 190, 168, 255),
              ),
            ),
            routerConfig: _router));
  }
}
