import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_item.dart';

class DetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailSection({Key? key, required this.data}) : super(key: key);
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
          DetailItem(label: "Reporter Name", value: data["citizenName"]),
          DetailItem(label: "Date & Time", value: _formatTimestamp(data["timestamp"])),
          DetailItem(label: "Incident Type", value: data["incidentType"]),
          DetailItem(label: "Injured", value: data["injuredCount"]?.toString()),
          DetailItem(label: "Severity", value: data["seriousness"]),
          DetailItem(label: "Location", value: data["address"]),
          DetailItem(label: "Landmark", value: data["landmark"]),
        ],
      ),
    );
  }
}
