import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_item.dart';

class LogBookDetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const LogBookDetailSection({Key? key, required this.data}) : super(key: key);
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
          Text("Details", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LogBookDetailItem(
              label: "Reporter Name", value: data["reporterName"]),
          LogBookDetailItem(
              label: "Date & Time Created", value: _formatTimestamp(data["timestamp"])),
              LogBookDetailItem(
              label: "Date & Time Updated", value: _formatTimestamp(data["updatedAt"])),
          LogBookDetailItem(label: "Status", value: data["status"]),
          LogBookDetailItem(label: "Legitimacy", value: data["scam"]),
          LogBookDetailItem(
              label: "# of Injured", value: data["injuredCount"]?.toString()),
          LogBookDetailItem(
              label: "Incident Type", value: data["incidentType"]),
          LogBookDetailItem(label: "Severity", value: data["seriousness"]),
          LogBookDetailItem(label: "Address", value: data["address"]),
          LogBookDetailItem(label: "Landmark", value: data["landmark"]),
          LogBookDetailItem(
              label: "Transported To", value: data["transportedTo"]),
        ],
      ),
    );
  }
}
