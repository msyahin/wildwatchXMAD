import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'get_started.dart';
import 'login.dart';
import 'home.dart';
import 'sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildWatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Minecraft',
      ),
      initialRoute: '/get-started',
      routes: {
        '/get-started': (context) => const GetStartedScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => const HomePage(), //Saje Test
      },
    );
  }
}
