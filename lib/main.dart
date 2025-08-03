import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login.dart'; // Import User Login Page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CompostMonitoringApp());
}

class CompostMonitoringApp extends StatelessWidget {
  const CompostMonitoringApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compost Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginSelectionPage(), // Start with User Login Page
    );
  }
}