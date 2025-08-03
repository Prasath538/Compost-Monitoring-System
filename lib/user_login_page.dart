import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'first_page.dart'; // Import FirstPage
import 'register_page.dart'; // Import Register Page

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Loading state

  void _handleLogin() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      // Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // ✅ Navigate to FirstPage after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FirstPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Full Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/agriculture1.jpg', // Ensure this image exists in assets
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Overlay to Enhance Readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),

          // ✅ Foreground UI Elements
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Login Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'USER LOGIN',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 15),

                  // ✅ Password Field
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  // ✅ Login Button with Loading Indicator
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Login'),
                        ),

                  const SizedBox(height: 20),

                  // ✅ Navigate to Register Page
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                    },
                    child: const Text(
                      "Don't have an account? Register here!",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
