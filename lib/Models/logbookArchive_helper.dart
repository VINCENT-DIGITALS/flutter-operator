import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class LogBookArchivingHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Date range fields for archiving
  static DateTime? startDate;
  static DateTime? endDate;
  static bool isDateRangeSelected = false;

  static Future<void> _archiveDocumentsInRange(
      BuildContext mainContext, DateTime startDate, DateTime endDate) async {
    final batch = _firestore.batch();
    final QuerySnapshot snapshot = await _firestore
        .collection('logBook')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate.add(const Duration(days: 1))))
        .get();

    if (snapshot.docs.isEmpty) {
      Fluttertoast.showToast(msg: 'No records found to archive in the selected range.');
      Navigator.of(mainContext).pop();
      return;
    }

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final docRef = doc.reference;
      batch.update(docRef, {'archived': true});
    }

    try {
      await batch.commit();
      Fluttertoast.showToast(
        msg: 'Log book records in the selected range have been archived.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error archiving documents: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      Navigator.of(mainContext).pop();
    }
  }

  static Future<void> _archiveAllDocuments(BuildContext mainContext) async {
    final batch = _firestore.batch();
    final QuerySnapshot snapshot = await _firestore.collection('logBook').get();

    if (snapshot.docs.isEmpty) {
      Fluttertoast.showToast(msg: 'No records found to archive.');
      Navigator.of(mainContext).pop();
      return;
    }

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final docRef = doc.reference;
      batch.update(docRef, {'archived': true});
    }

    try {
      await batch.commit();
      Fluttertoast.showToast(
        msg: 'All log book records have been archived.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error archiving documents: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      Navigator.of(mainContext).pop();
    }
  }

  static Future<void> initialConfirmation(BuildContext mainContext) async {
    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Select Archiving Option'),
        content: Text('Choose to archive all records or within a date range.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              confirmAndArchiveLogBook(mainContext, archiveAll: true);
            },
            child: Text('Archive All', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDateRangeDialog(mainContext);
            },
            child: Text('Select Date Range', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  static Future<void> _showDateRangeDialog(BuildContext mainContext) async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: mainContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Select Date Range for Archiving'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Start Date'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                  subtitle: Text(
                    startDate != null
                        ? DateFormat('yyyy-MM-dd').format(startDate!)
                        : 'Select start date',
                  ),
                ),
                ListTile(
                  title: Text('End Date'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  subtitle: Text(
                    endDate != null
                        ? DateFormat('yyyy-MM-dd').format(endDate!)
                        : 'Select end date',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (startDate == null || endDate == null) {
                    Fluttertoast.showToast(
                      msg: 'Please select both start and end dates.',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else if (startDate!.isAfter(endDate!)) {
                    Fluttertoast.showToast(
                      msg: 'Start date cannot be after end date.',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else {
                    Navigator.of(context).pop();
                    confirmAndArchiveLogBook(
                      mainContext,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  }
                },
                child: Text('Archive', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> confirmAndArchiveLogBook(
      BuildContext mainContext, {bool archiveAll = false, DateTime? startDate, DateTime? endDate}) async {
    // Authentication and archiving logic similar to deletion implementation
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Enter Password to Confirm Archiving'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              Navigator.of(context).pop();

              if (password.isNotEmpty) {
                try {
                  final user = _auth.currentUser;

                  if (user == null) {
                    Fluttertoast.showToast(
                        msg: 'User is not logged in.', toastLength: Toast.LENGTH_LONG);
                    return;
                  }

                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );

                  await user.reauthenticateWithCredential(credential);

                  _showLoadingDialog(mainContext);

                  if (archiveAll) {
                    await _archiveAllDocuments(mainContext);
                  } else if (startDate != null && endDate != null) {
                    await _archiveDocumentsInRange(mainContext, startDate, endDate);
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: 'Incorrect password or reauthentication failed.', toastLength: Toast.LENGTH_LONG);
                }
              } else {
                Fluttertoast.showToast(msg: 'Password cannot be empty.', toastLength: Toast.LENGTH_LONG);
              }
            },
            child: Text('Confirm', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Archiving... Please wait"),
            ],
          ),
        ),
      ),
    );
  }
}
