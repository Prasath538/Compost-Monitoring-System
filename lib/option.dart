import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'compliant_detail.dart';
import 'fertilizer_detail.dart'; // Import Fertilizer Verification Page

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Options',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 8,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/a8.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3), // Adds a slight overlay for readability
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton(
                    context,
                    'Complaint Details',
                    Icons.report_problem_rounded,
                    Colors.blueAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ComplaintDetailsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildOptionButton(
                    context,
                    'Fertilizer Details',
                    Icons.agriculture,
                    Colors.orangeAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FertilizerVerification()),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Button builder for options with icons
  Widget _buildOptionButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(2, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logout button with icon
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginSelectionPage()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.redAccent.withOpacity(0.8), Colors.redAccent]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.redAccent.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(2, 4)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
