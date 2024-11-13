import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'activity_item.dart';

String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'N/A';
  final dateTime = timestamp.toDate();
  return DateFormat('MMMM d, y h:mm a').format(dateTime);
}

Widget buildRecentActivity() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      var recentReports = snapshot.data!.docs;

      if (recentReports.isEmpty) {
        // Show a message when no reports are available
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blueGrey.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blueGrey,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent reports available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reports will be shown here once they are added.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(
                color: Color.fromARGB(179, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (var report in recentReports)
              buildActivityItem(
                report['incidentType'] ?? 'No incident type available',
                _formatTimestamp(report['timestamp']),
              ),
          ],
        ),
      );
    },
  );
}
