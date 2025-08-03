import 'package:flutter/material.dart';

class OfficerDetailsPage extends StatelessWidget {
  const OfficerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Officer Details')),
      body: const Center(
        child: Text(
          'Welcome, Agriculture Officer!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
