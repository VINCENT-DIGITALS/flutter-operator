import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/view_Logbook_widget/detail_item.dart';

class SMSDetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const SMSDetailSection({Key? key, required this.data}) : super(key: key);
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
          Text(" SMS Details", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LogBookDetailItem(label: "Message", value: data["reporterName"]),
          LogBookDetailItem(
              label: "Date & Time Created",
              value: _formatTimestamp(data["timestamp"])),
          LogBookDetailItem(label: "# Failed", value: data["numFailed"]),
          LogBookDetailItem(label: "# Sent", value: data["numSuccess"]),
          LogBookDetailItem(label: "Status", value: data["status"]),
        ],
      ),
    );
  }
}
