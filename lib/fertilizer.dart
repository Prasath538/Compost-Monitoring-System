import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FertilizerDetails extends StatefulWidget {
  const FertilizerDetails({super.key});

  @override
  _FertilizerDetailsState createState() => _FertilizerDetailsState();
}

class _FertilizerDetailsState extends State<FertilizerDetails> {
  List<Map<String, dynamic>> fertilizerDataList = [];
  Map<String, dynamic>? userDetails;
  bool isLoading = true;
  String? email;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email = user.email;
        if (email == null || email!.isEmpty) return;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('register')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          setState(() {
            userDetails = userSnapshot.docs.first.data() as Map<String, dynamic>;
          });
        }

        await fetchAndProcessSensorData();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchAndProcessSensorData() async {
    try {
      QuerySnapshot sensorSnapshot = await FirebaseFirestore.instance
          .collection('sensorData')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (sensorSnapshot.docs.isEmpty) return;

      var latestSensorData = sensorSnapshot.docs.first.data() as Map<String, dynamic>;
      double latestPh = latestSensorData['pH']?.toDouble() ?? -1;
      Timestamp latestTimestamp = latestSensorData['timestamp'];

      if (latestPh < 6.5 || latestPh > 8.0) return;

      QuerySnapshot historySnapshot = await FirebaseFirestore.instance
          .collection('fertilizerhistory')
          .where('userEmail', isEqualTo: email)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      double lastStoredPh = historySnapshot.docs.isNotEmpty
          ? (historySnapshot.docs.first.data() as Map<String, dynamic>)['pH'].toDouble()
          : -1;

      if (lastStoredPh == -1 || (latestPh - lastStoredPh).abs() >= 0.1) {
        await FirebaseFirestore.instance.collection('fertilizerhistory').add({
          'userEmail': email,
          'pH': latestPh,
          'timestamp': latestTimestamp,
        });
      }

      await fetchStoredFertilizerData();
    } catch (e) {
      print("Error processing sensor data: $e");
    }
  }

  Future<void> fetchStoredFertilizerData() async {
    try {
      QuerySnapshot storedDataSnapshot = await FirebaseFirestore.instance
          .collection('fertilizerhistory')
          .where('userEmail', isEqualTo: email)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        fertilizerDataList = storedDataSnapshot.docs.map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'docId': doc.id,
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching stored data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteFertilizerEntry(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('fertilizerhistory').doc(docId).delete();
      fetchStoredFertilizerData();
    } catch (e) {
      print("Error deleting entry: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fertilizer History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildUserDetailsCard(),
                Expanded(
                  child: fertilizerDataList.isEmpty
                      ? Center(
                          child: Text(
                            "No Fertilizer Data Available",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: fertilizerDataList.length,
                          itemBuilder: (context, index) {
                            return _buildDetailCard(fertilizerDataList[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserDetailsCard() {
    if (userDetails == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailItem(Icons.person, "Username", userDetails!['username'] ?? 'N/A'),
            _buildDetailItem(Icons.work, "Post", userDetails!['post'] ?? 'N/A'),
            _buildDetailItem(Icons.location_on, "District", userDetails!['district'] ?? 'N/A'),
            _buildDetailItem(Icons.phone, "Mobile", userDetails!['mobileNumber'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> fertilizerData) {
    Timestamp? timestamp = fertilizerData['timestamp'];
    String formattedDate = timestamp != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate()) : 'Unknown';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text("pH Level: ${fertilizerData['pH']?.toStringAsFixed(2) ?? 'N/A'}"),
        subtitle: Text("Date: $formattedDate"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => deleteFertilizerEntry(fertilizerData['docId']),
        ),
      ),
    );
  }
}
