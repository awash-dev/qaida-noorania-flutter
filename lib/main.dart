import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final loggedIn = await Storage.isLoggedIn();
  runApp(QaidaApp(initiallyLoggedIn: loggedIn));
}

class QaidaApp extends StatelessWidget {
  final bool initiallyLoggedIn;
  const QaidaApp({super.key, required this.initiallyLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القاعدة النورانية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: initiallyLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}