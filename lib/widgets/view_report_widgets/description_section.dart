import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const DescriptionSection({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? mediaUrl = data["mediaUrl"];

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
          Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(data["incidentDesc"] ?? "N/A"),
          SizedBox(height: 8),
          if (mediaUrl != null && mediaUrl.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                final Uri uri = Uri.parse(mediaUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text("View Attachment"),
            ),
        ],
      ),
    );
  }
}
