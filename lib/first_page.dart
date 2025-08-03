import 'package:flutter/material.dart';
import 'second_page.dart';
import 'profile.dart';
import 'global_state.dart';
import 'login.dart';
import 'compliant.dart';
import 'help.dart';
import 'fertilizer.dart';
import 'history.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'COMPOST MONITORING',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComplaintPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'COMPLIANT',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightGreen),
              child: Text(
                'MENU',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            _buildDrawerItem(Icons.person, "PROFILE", () => _navigateTo(const ProfilePage())),
            _buildDrawerItem(Icons.history, "HISTORY", () => _navigateTo(const PaymentHistoryPage())),
            _buildDrawerItem(Icons.schedule, "COMPOST SCHEDULES", () => _navigateTo(const FertilizerDetails())),
            _buildDrawerItem(Icons.help, "HELP", () => _navigateTo(const HelpPage())),
            _buildDrawerItem(Icons.logout, "LOGOUT", _showLogoutDialog),
          ],
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/agriculture3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  GlobalState.isRunning.value = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FetchSensorData()),
                  );
                },
                child: ValueListenableBuilder<bool>( 
                  valueListenable: GlobalState.isRunning,
                  builder: (context, isRunning, child) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: isRunning ? Colors.grey : Colors.lightGreen[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isRunning ? 'RUNNING' : 'START',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  GlobalState.isRunning.value = false;
                },
                child: const Text('STOP', style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginSelectionPage()),
    );
  }
}
