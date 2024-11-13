import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CitizenProfileDialog extends StatefulWidget {
  final String userId;

  CitizenProfileDialog({required this.userId});

  @override
  _CitizenProfileDialogState createState() => _CitizenProfileDialogState();
}

class _CitizenProfileDialogState extends State<CitizenProfileDialog> {
  Map<String, dynamic>? userData;
  int reportCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchReportCount();
  }

  Future<void> _fetchUserData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('citizens')
          .doc(widget.userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          userData = docSnapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data.')),
      );
    }
  }

  Future<void> _fetchReportCount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('reporterId', isEqualTo: widget.userId)
          .get();

      setState(() {
        reportCount = querySnapshot.docs.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load report count.')),
      );
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMMM d, y h:mm a').format(date.toDate());
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildProfileItem(String label, dynamic value, IconData icon, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: fontSize + 4),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${value ?? 'N/A'}",
                  style: TextStyle(fontSize: fontSize, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth > 600 ? 18 : 14; // Adjust font size based on screen width
    final double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with profile image
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Citizen Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize + 4),
            ),
            SizedBox(height: 8),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : userData != null
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileItem("Display Name", userData!['displayName'], Icons.person, fontSize),
                                _buildProfileItem("Email", userData!['email'], Icons.email, fontSize),
                                _buildProfileItem("Address", userData!['address'], Icons.location_on, fontSize),
                                _buildProfileItem("Status", userData!['status'], Icons.info, fontSize),
                                _buildProfileItem("Type", userData!['type'], Icons.category, fontSize),
                                _buildProfileItem(
                                  "Privacy Policy",
                                  userData!['privacyPolicyAcceptance'] == true ? 'Accepted' : 'Not Accepted',
                                  Icons.lock,
                                  fontSize,
                                ),
                                _buildProfileItem("Created At", formatDate(userData!['createdAt']), Icons.calendar_today, fontSize),
                                _buildProfileItem("Last Updated", formatDate(userData!['lastUpdated']), Icons.update, fontSize),
                                _buildProfileItem("Report Count", reportCount, Icons.article, fontSize),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(child: Text('No user data available.')),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
