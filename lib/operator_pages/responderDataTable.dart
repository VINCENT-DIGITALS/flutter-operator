import 'package:administrator/widgets/responder_profile/ResponderProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../services/database_service.dart';

class UserDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final List<String> columnKeys;
  final BuildContext context;
  final DatabaseService _dbService =
      DatabaseService(); // Instantiate DatabaseService

  UserDataTableSource(this.data, this.columnKeys, this.context);

  String _truncateString(String value) {
    return value.length > 25 ? '${value.substring(0, 20)}...' : value;
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
    return DataRow.byIndex(
      index: index,
      cells: columnKeys.map((key) {
        if (key == "actions") {
          return DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: 'View Profile',
                child: IconButton(
                  icon: Icon(Icons.person, color: Colors.blueAccent),
                  onPressed: () {
                    // Implement view profile logic here
                    showDialog(
                      context: context,
                      builder: (context) => ResponderProfileDialog(userId: user['id']),
                    );
                  },
                ),
              ),
              Tooltip(
                message: user['status'] == 'Activated'
                    ? 'Disable Account'
                    : 'Enable Account',
                child: IconButton(
                  icon: Icon(
                    user['status'] == 'Activated' ? Icons.block : Icons.check,
                    color: user['status'] == 'Activated'
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                  onPressed: () {
                    _showDisableAccountDialog(
                        context, user['id'], user['status']);
                  },
                ),
              ),
            ],
          ));
        } else if (key == "createdAt") {
          // Use _formatTimestamp for createdAt field
          return DataCell(Text(
            _formatTimestamp(user[key] as Timestamp?),
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ));
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

  void _showDisableAccountDialog(
      BuildContext context, String userId, String currentStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentStatus == 'Activated'
              ? 'Disable Account'
              : 'Enable Account'),
          content: Text(currentStatus == 'Activated'
              ? 'Are you sure you want to disable this account?'
              : 'Are you sure you want to enable this account?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(currentStatus == 'Activated' ? 'Disable' : 'Enable'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: currentStatus == 'Activated'
                    ? Colors.redAccent
                    : Colors.green,
              ),
              onPressed: () async {
                try {
                  await _dbService.toggleResponderStatus(userId, currentStatus);
                  Fluttertoast.showToast(
                    msg: currentStatus == 'Activated'
                        ? "Account disabled successfully"
                        : "Account enabled successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Failed to update account status: $e",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } finally {
                  Navigator.of(context).pop();
                  // print("Disabled account of $userId");
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
