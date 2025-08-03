import 'package:flutter/material.dart';
import 'user_login_page.dart'; // Import the actual User Login Page
import 'login_officer.dart'; // Import the Officer Login Page

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginSelectionPage(),
  ));
}

class LoginSelectionPage extends StatelessWidget {
  const LoginSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Full Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/agriculture_ad.jpg', // Ensure this image exists in assets
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Overlay to enhance readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),

          // ✅ Foreground UI Elements
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ App Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LOGIN PAGE',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ✅ Login for User Button
                _buildLoginButton(
                  context,
                  'LOGIN FOR USER',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserLoginPage()),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // ✅ Login for Agriculture Officer Button
                _buildLoginButton(
                  context,
                  'LOGIN FOR AGRICULTURE OFFICER',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OfficerLoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Reusable button widget
  Widget _buildLoginButton(BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Slight transparency
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
