import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'users_item.dart';

String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'N/A';
  final dateTime = timestamp.toDate();
  return DateFormat('MMMM d, y h:mm a').format(dateTime);
}

Widget buildRecentUsers() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('citizens')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      var recentCitizens = snapshot.data!.docs;

      if (recentCitizens.isEmpty) {
        // Show a message when no recent users are available
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
                  'No recent users available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Users will appear here once they have signed up.',
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
              'Recent Users',
              style: TextStyle(
                color: Color.fromARGB(179, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (var citizen in recentCitizens)
              buildUserItem(
                citizen['displayName'] ?? 'No name',
                _formatTimestamp(citizen['createdAt']),
              ),
          ],
        ),
      );
    },
  );
}
