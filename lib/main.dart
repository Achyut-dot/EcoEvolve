import 'package:ecoevolve/pages/gov_view.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onboarding pages/getting_started_page.dart';
import 'onboarding pages/login_page.dart';
import 'onboarding pages/forget_password_page.dart';
import 'onboarding pages/sign_up_page.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      initialRoute: '/gettingStarted',
      debugShowCheckedModeBanner: false,
      routes: {
        '/gettingStarted': (context) => const GettingStartedPage(),
        '/login': (context) => LoginPage(),
        '/forgetPassword': (context) => ForgetPasswordPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const MainScreen(),
        '/govView': (context) => const ViewComplaintsPage(),
      },
    );
  }
}
