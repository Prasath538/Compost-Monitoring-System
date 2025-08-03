import 'package:flutter/material.dart';

void main() {
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
      home: const CompostMonitoringPage(),
    );
  }
}

class CompostMonitoringPage extends StatelessWidget {
  const CompostMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COMPOST MONITORING'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // ✅ Navigate to Monitoring Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MonitoringPage()),
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'START',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Second Page (Monitoring Page)
class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Data'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDataBox("HUMIDITY"),
            buildDataBox("TEMPERATURE"),
            buildDataBox("PH RANGE"),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTimeBox("TIME"),
                buildTimeBox("EST. TIME"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for sensor data boxes
  Widget buildDataBox(String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Container(
          width: 200,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // Widget for time boxes
  Widget buildTimeBox(String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
