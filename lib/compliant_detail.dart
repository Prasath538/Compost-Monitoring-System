import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintDetailsPage extends StatelessWidget {
  const ComplaintDetailsPage({super.key});

  /// Fetch user details from Firestore based on UID
  Future<Map<String, dynamic>?> fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('register').doc(uid).get();
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
    return null;
  }

  /// Update complaint status to 'Verified'
  Future<void> updateComplaintStatus(String docId) async {
    await FirebaseFirestore.instance.collection('compliant').doc(docId).update({
      'status': 'Verified',
    });
  }

  /// Delete complaint from Firestore
  Future<void> deleteComplaint(String docId, BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text("Delete Complaint"),
        content: const Text("Are you sure you want to delete this complaint?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('compliant').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Complaint Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('compliant')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaintData = complaints[index].data() as Map<String, dynamic>;
              final String docId = complaints[index].id;
              final String uid = complaintData['uid'] ?? '';
              final String status = complaintData['status'] ?? 'Not Seen';

              return FutureBuilder<Map<String, dynamic>?>(
                future: uid.isNotEmpty ? fetchUserDetails(uid) : Future.value(null),
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: status == 'Not Seen' ? Colors.orange[100] : Colors.green[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_circle, color: Colors.blueAccent, size: 30),
                              const SizedBox(width: 10),
                              Text(
                                userData?['username'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: status == 'Not Seen' ? Colors.redAccent : Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "📌 ${complaintData['complaint'] ?? 'No details'}",
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          if (userData != null) ...[
                            Text("🏢 Post: ${userData['post'] ?? 'N/A'}", style: _infoTextStyle()),
                            Text("🏙 City: ${userData['city'] ?? 'N/A'}", style: _infoTextStyle()),
                            Text("📍 District: ${userData['district'] ?? 'N/A'}", style: _infoTextStyle()),
                            Text("📮 Pincode: ${userData['pincode'] ?? 'N/A'}", style: _infoTextStyle()),
                            Text("📞 Mobile: ${userData['mobileNumber'] ?? 'N/A'}", style: _infoTextStyle()),
                          ] else
                            const Text("User details not available"),

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      title: const Text(
                                        "Complaint Details",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      content: Text(
                                        complaintData['complaint'] ?? 'No details',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Close"),
                                        ),
                                        ElevatedButton(
                                          onPressed: status == "Verified"
                                              ? null // Disable button if already verified
                                              : () async {
                                                  await updateComplaintStatus(docId);
                                                  Navigator.pop(context);
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: status == "Verified" ? Colors.grey : Colors.blue,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text("Verify", style: TextStyle(fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline, color: Colors.white),
                                label: const Text("Details"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => deleteComplaint(docId, context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Helper method for text styling
  static TextStyle _infoTextStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500);
  }
}
