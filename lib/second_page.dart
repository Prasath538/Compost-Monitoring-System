import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchSensorData extends StatefulWidget {
  const FetchSensorData({super.key});

  @override
  State<FetchSensorData> createState() => _FetchSensorDataState();
}

class _FetchSensorDataState extends State<FetchSensorData> {
  final CollectionReference sensorCollection =
      FirebaseFirestore.instance.collection('sensorData');
  final String documentName = "latestData";

  bool hasNotified = false; // Prevents multiple notifications

  Color getStatusColor(double value, double min, double max) {
    if (value < min) {
      return Colors.orangeAccent; // Warning (Too Low)
    } else if (value > max) {
      return Colors.redAccent; // Critical (Too High)
    }
    return Colors.green; // Safe Range
  }

  double getProgress(double value, double min, double max) {
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  void showCompletionDialog() {
    if (!hasNotified) {
      hasNotified = true; // Ensure dialog shows only once
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Composting Complete"),
          content: const Text("Composting can be successfully finished!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to go behind app bar
      appBar: AppBar(
        title: const Text('Compost Monitoring'),
        backgroundColor: Colors.green.shade700.withOpacity(0.9),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/agriculture4.jpg",
              fit: BoxFit.cover,
            ),
          ),
          
          // ✅ Semi-transparent Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Dark overlay for readability
            ),
          ),

          // ✅ Content
          StreamBuilder<DocumentSnapshot>(
            stream: sensorCollection.doc(documentName).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("No sensor data available", style: TextStyle(color: Colors.white)));
              }

              var sensorData = snapshot.data!.data() as Map<String, dynamic>;
              double temperature = sensorData['temperature'] ?? 0.0;
              double humidity = sensorData['humidity'] ?? 0.0;
              double pH = sensorData['pH'] ?? 0.0;

              // ✅ Convert Firestore Timestamp to readable DateTime
              Timestamp? timestamp = sensorData['timestamp'] as Timestamp?;
              String lastUpdated = timestamp != null
                  ? "${timestamp.toDate().toLocal()}"
                  : "Unknown Time";

              // ✅ Show notification when pH is in the ideal range (6.5 - 8)
              if (pH >= 6.5 && pH <= 8) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showCompletionDialog();
                });
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildSensorCard(
                      title: "Temperature",
                      value: "$temperature°C",
                      icon: Icons.thermostat,
                      color: getStatusColor(temperature, 60, 70),
                      progress: getProgress(temperature, 60, 70),
                      safeRange: "60 - 70°C",
                    ),
                    const SizedBox(height: 15),
                    _buildSensorCard(
                      title: "Humidity",
                      value: "$humidity%",
                      icon: Icons.water_drop,
                      color: getStatusColor(humidity, 40, 60),
                      progress: getProgress(humidity, 40, 60),
                      safeRange: "40 - 60%",
                    ),
                    const SizedBox(height: 15),
                    _buildSensorCard(
                      title: "pH Level",
                      value: "$pH",
                      icon: Icons.science,
                      color: getStatusColor(pH, 6.5, 8),
                      progress: getProgress(pH, 6.5, 8),
                      safeRange: "6.5 - 8",
                    ),
                    const SizedBox(height: 15),
                    _buildOverallProgress(temperature, humidity, pH),
                    const SizedBox(height: 15),
                    Text(
                      "Last Updated: $lastUpdated",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
    required String safeRange,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(1.0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Safe Range: $safeRange",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(double temp, double humidity, double pH) {
    double overallProgress = (getProgress(temp, 60, 70) +
            getProgress(humidity, 40, 60) +
            getProgress(pH, 6.5, 8)) /
        3;

    // ✅ Force 100% completion if pH is in range
    if (pH >= 6.5 && pH <= 8) {
      overallProgress = 1.0;
    }

    return Column(
      children: [
        const Text(
          "Overall Composting Progress",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                value: overallProgress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green.shade700,
              ),
            ),
            Text(
              "${(overallProgress * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
