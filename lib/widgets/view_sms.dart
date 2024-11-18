import 'package:administrator/widgets/view_Logbook_widget/description_section.dart';
import 'package:administrator/widgets/view_Logbook_widget/detail_section.dart';
import 'package:administrator/widgets/view_Logbook_widget/location_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../operator_pages/smsPage/detailSection.dart';
import 'view_Logbook_widget/responder_detail_section.dart';
import 'view_Logbook_widget/vehicle_detail_section.dart';
import 'view_Logbook_widget/victim_detail_section.dart';

class ViewSMSDialog extends StatelessWidget {
  final String SMSID;

  const ViewSMSDialog({Key? key, required this.SMSID}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchLogBookData() async {
    try {
      final reportDoc =
          await FirebaseFirestore.instance.collection('sms').doc(SMSID).get();

      if (reportDoc.exists) {
        final reportData = reportDoc.data()!;

        return reportData;
      }
    } catch (e) {
      print("Error fetching report data: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchLogBookData(),
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
                  width: constraints.maxWidth * 0.2,
                  height: constraints.maxHeight * 0.4,
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
                                  SMSDetailSection(data: data),
                                  SizedBox(height: 8),
                                ],
                              )
                            : Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      SMSDetailSection(data: data),
                                      SizedBox(height: 8),
                                    ],
                                  ),
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