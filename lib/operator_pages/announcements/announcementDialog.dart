import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementDetailDialog extends StatelessWidget {
  final String title;
  final String content;
  final DateTime timestamp;

  const AnnouncementDetailDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.timestamp,
  }) : super(key: key);

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('MMMM d, y h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.35, // 80% of screen width
                maxHeight: constraints.maxHeight * 0.35, // 80% of screen height
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _formatTimestamp(timestamp), // Use _formatTimestamp here
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 16),
                    Text(
                      content,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
