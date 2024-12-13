import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../../services/database_service.dart';
import '../../../widgets/view_incident_report.dart';

class ArchivedIncidentReportDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final List<String> columnKeys;
  final BuildContext context;
  final DatabaseService _dbService = DatabaseService();

  ArchivedIncidentReportDataTableSource(
      this.data, this.columnKeys, this.context);

  String _truncateString(String value) {
    return value.length > 25 ? '${value.substring(0, 10)}...' : value;
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final user = data[index];

    // // Debugging logs to check field values
    // print('AcceptedBy: ${user['acceptedBy']}');
    // print('IncidentType: ${user['incidentType']}');
    // print('InjuredCount: ${user['injuredCount']}');

    return DataRow.byIndex(
      index: index,
      cells: columnKeys.map((key) {
        if (key == "actions") {
          return DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(
                message: 'View Report',
                child: IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return ViewReportDialog(reportId: user['id']);
                      },
                    );
                  },
                ),
              ),
              Tooltip(
                message: 'Unarchived Report',
                child: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    _showArchiveLogBookDialog(context, user['id']);
                  },
                ),
              ),
            ],
          ));
        } else if (key == "timestamp") {
          return DataCell(Text(
            _formatTimestamp(user[key] as Timestamp?),
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ));
        } else if (key == "seriousness") {
          // Style the cell by highlighting the text based on the seriousness value
          final seriousness = user[key]?.toString() ?? 'N/A';
          Color seriousnessColor;

          switch (seriousness.toLowerCase()) {
            case 'severe':
              seriousnessColor = Colors.redAccent;
              break;
            case 'moderate':
              seriousnessColor = Colors.orangeAccent;
              break;
            case 'minor':
              seriousnessColor = Color.fromARGB(255, 155, 155, 7);
              break;
            default:
              seriousnessColor =
                  Colors.black87; // Default color for unknown values
          }

          return DataCell(
            Text(
              seriousness,
              style: TextStyle(
                color: seriousnessColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          );
        } else {
           return DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Tooltip(
                message: user[key]?.toString() ?? 'N/A',
                child: Text(
                  _truncateString(user[key]?.toString() ?? 'N/A'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  void _showArchiveLogBookDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('UnArchive Report'),
          content: Text(
              'Are you sure you want to archive this Report? You can restore it later if needed.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Unarchive'),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orangeAccent),
              onPressed: () async {
                try {
                  await _dbService.unArchiveReport(userId);
                  Fluttertoast.showToast(
                    msg: "Report archived successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Failed to archive the Report",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } finally {
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
