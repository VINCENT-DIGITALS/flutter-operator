import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';

class SmsDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final List<String> columnKeys;
  final BuildContext context;
  final DatabaseService _dbService = DatabaseService();

  SmsDataTableSource(this.data, this.columnKeys, this.context);

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
                    // showDialog(
                    //   context: context,
                    //   barrierDismissible: true,
                    //   builder: (BuildContext context) {
                    //     return ViewReportDialog(reportId: user['id']);
                    //   },
                    // );
                  },
                ),
              ),
              Tooltip(
                message: 'Delete Report',
                child: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    _showDeleteReportDialog(context, user['id']);
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
        } else {
          return DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _truncateString(user[key]?.toString() ?? 'N/A'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  void _showDeleteReportDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Report'),
          content: Text(
              'Are you sure you want to delete this report? This action is unrecoverable.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent),
              onPressed: () async {
                try {
                  await _dbService.deleteReport(userId);
                  Fluttertoast.showToast(
                    msg: "Report deleted successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Failed to delete the report",
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
