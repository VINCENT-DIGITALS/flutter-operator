import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'list_responder.dart';

class LogBookResponderDetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const LogBookResponderDetailSection({Key? key, required this.data}) : super(key: key);

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
  }

  // Extract responder names from the 'responders' array
  List<String> _getResponderNames() {
    final responders = data["responders"] as List<dynamic>? ?? [];
    return responders
        .map((responder) => responder["responderName"]?.toString() ?? 'Unknown')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final responderNames = _getResponderNames(); // List of responder names

    return Container(
      padding: EdgeInsets.all(12),
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Responders", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          // Display list of responder names
          ...responderNames.map((name) => LogBookResponderListItem(label: "Responder", value: name)).toList(),
        ],
      ),
    );
  }
}
