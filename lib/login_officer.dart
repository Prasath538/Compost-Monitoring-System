import 'package:flutter/material.dart';
import 'package:flutter_application_1/option.dart'; // Import the Officer Details Page

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OfficerLoginPage(),
  ));
}

class OfficerLoginPage extends StatefulWidget {
  const OfficerLoginPage({super.key});

  @override
  _OfficerLoginPageState createState() => _OfficerLoginPageState();
}

class _OfficerLoginPageState extends State<OfficerLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dummy credentials (you can replace with your actual authentication logic)
  final String defaultUsername = "officer";
  final String defaultPassword = "password123";

  // Method to check login credentials
  void _login() {
    if (_usernameController.text == defaultUsername && _passwordController.text == defaultPassword) {
      // Navigate to details page if credentials are correct
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OptionsPage()),
      );
    } else {
      // Show error message if credentials are incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Username or Password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agriculture Officer Login')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/a7.jpg'), // Set your background image here
            fit: BoxFit.cover, // Ensure the image covers the screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Officer Login',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ensure text is visible on the background
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white), // Ensures typed text is visible
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white), // White label text
                  filled: true,
                  fillColor: Colors.black54, // Dark background for input
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white70), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white), // White border on focus
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white), // Ensures typed text is visible
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white), // White label text
                  filled: true,
                  fillColor: Colors.black54, // Dark background for input
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white70), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white), // White border on focus
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button background color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
