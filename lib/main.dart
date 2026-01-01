import 'package:flutter/material.dart';
import 'package:isar_db/view/v_splash.dart';

void main() {
  // Ensure Isar is initialized before the app runs.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IsarApp());
}

class IsarApp extends StatelessWidget {
  const IsarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isar DB Tutorial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: false),
      home: const SplashScreen(),
    );
  }
}
