import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> instructions = [
      "Ensure your device is connected to the internet before starting the app.",
      "Use Wi-Fi or mobile data for a stable connection.",
      "If using Wi-Fi, make sure the signal strength is strong.",
      "If using mobile data, check if your data plan is active.",
      "Restart the router if experiencing connectivity issues.",
      "Allow the app necessary internet permissions if prompted.",
      "Ensure the app is updated to the latest version.",
      "Enable background data usage for uninterrupted functionality.",
      "Use the app in areas with good network coverage.",
      "If the app fails to load data, try refreshing it.",
      "Check if your internet service provider is facing outages.",
      "Avoid using VPNs that may block app access.",
      "Ensure that firewall or antivirus software isn't restricting internet access.",
      "Reinstall the app if connection problems persist.",
      "Use the app’s troubleshooting section for more help.",
      "Check for server maintenance notifications within the app.",
      "Ensure the device time and date are correctly set.",
      "Try switching between Wi-Fi and mobile data if one is unstable.",
      "Contact your internet service provider for further assistance.",
      "If all else fails, reach out to the app's support team for help.",
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Help & Instructions",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: instructions.length,
              itemBuilder: (context, index) {
                return _buildInstructionCard(index + 1, instructions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildInstructionCard(int number, String instruction) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.9),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            number.toString(),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        title: Text(
          instruction,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: const Icon(LucideIcons.info, color: Colors.blueAccent),
      ),
    );
  }
}
