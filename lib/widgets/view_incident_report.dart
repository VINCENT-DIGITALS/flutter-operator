import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'view_report_widgets/description_section.dart';
import 'view_report_widgets/detail_section.dart';
import 'view_report_widgets/location_section.dart';

class ViewReportDialog extends StatelessWidget {
  final String reportId;

  const ViewReportDialog({Key? key, required this.reportId}) : super(key: key);

Future<Map<String, dynamic>?> _fetchReportData() async {
  try {
    final reportDoc = await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .get();

    if (reportDoc.exists) {
      final reportData = reportDoc.data()!;
      
      // Fetch citizen's name using reporterId
      final reporterId = reportData['reporterId'] as String;
      final citizenDoc = await FirebaseFirestore.instance
          .collection('citizens')
          .doc(reporterId)
          .get();

      if (citizenDoc.exists) {
        // Add the citizen's name to report data
        reportData['citizenName'] = citizenDoc['displayName'];
      } else {
        reportData['citizenName'] = 'Unknown'; // Handle missing citizen data
      }

      return reportData;
    }
  } catch (e) {
    print("Error fetching report data: $e");
  }
  return null;
}


  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching report data"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Report not found"));
          } else {
            final data = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen = constraints.maxWidth < 600;

                return Container(
                  padding: EdgeInsets.all(16.0),
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.8,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        isSmallScreen
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DetailSection(data: data),
                                  SizedBox(height: 8),
                                  DescriptionSection(data: data),
                                  SizedBox(height: 8),
                                  LocationSection(context: context, data: data),
                                ],
                              )
                            : Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.start,
                                children: [
                                  DetailSection(data: data),
                                  DescriptionSection(data: data),
                                  LocationSection(context: context, data: data),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
