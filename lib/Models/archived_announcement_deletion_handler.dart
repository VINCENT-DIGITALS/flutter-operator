import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ArchivedAnnouncementDeletionHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to delete documents in the 'announcements' collection where archived is false
  static Future<void> _deleteUnarchivedDocuments(BuildContext mainContext) async {
    final batch = _firestore.batch();
    final QuerySnapshot snapshot = await _firestore
        .collection('announcements')
        .where('archived', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      Fluttertoast.showToast(msg: 'No unarchived records found to delete.');
      Navigator.of(mainContext).pop(); // Close loading dialog if nothing to delete
      return;
    }

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    try {
      await batch.commit();
      Fluttertoast.showToast(
        msg: 'All unarchived announcement records have been deleted.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error deleting documents: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      Navigator.of(mainContext).pop(); // Close loading dialog
    }
  }

  // Function to show the initial confirmation dialog
  static Future<void> initialConfirmation(BuildContext mainContext) async {
    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
            'This will permanently delete all unarchived announcement records. Do you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              confirmAndDeleteUnarchived(mainContext); // Proceed with deletion
            },
            child: Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Function to reauthenticate the user and proceed with deletion
  static Future<void> confirmAndDeleteUnarchived(BuildContext mainContext) async {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Enter Password to Confirm Deletion'),
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
              Navigator.of(context).pop(); // Close the password dialog

              if (password.isNotEmpty) {
                try {
                  final user = _auth.currentUser;

                  if (user == null) {
                    Fluttertoast.showToast(
                        msg: 'User is not logged in.',
                        toastLength: Toast.LENGTH_LONG);
                    return;
                  }

                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );

                  // Attempt to reauthenticate
                  await user.reauthenticateWithCredential(credential);

                  // Show the loading dialog using the main context
                  _showLoadingDialog(mainContext);

                  // Proceed with deletion of unarchived documents
                  await _deleteUnarchivedDocuments(mainContext);
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: 'Incorrect password or reauthentication failed.',
                      toastLength: Toast.LENGTH_LONG);
                }
              } else {
                Fluttertoast.showToast(
                    msg: 'Password cannot be empty.',
                    toastLength: Toast.LENGTH_LONG);
              }
            },
            child: Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Function to show a loading dialog
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
              Text("Deleting... Please wait"),
            ],
          ),
        ),
      ),
    );
  }
}
