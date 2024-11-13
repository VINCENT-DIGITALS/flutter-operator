import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LogBookDeletionHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to delete all documents in the 'logBook' collection
  static Future<void> _deleteAllDocuments(BuildContext mainContext) async {
    final batch = _firestore.batch();
    final QuerySnapshot snapshot = await _firestore.collection('logBook').get();

    if (snapshot.docs.isEmpty) {
      Fluttertoast.showToast(msg: 'No records found to delete.');
      Navigator.of(mainContext).pop();  // Close loading dialog if nothing to delete
      return;
    }

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    try {
      await batch.commit();
      Fluttertoast.showToast(
        msg: 'All log book records have been deleted.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error deleting documents: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      Navigator.of(mainContext).pop();  // Close loading dialog
    }
  }

  // Function to show the initial confirmation dialog
  static Future<void> initialConfirmation(BuildContext mainContext) async {
    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
            'This will permanently delete all log book records. Do you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              confirmAndDeleteLogBook(mainContext); // Pass main context to avoid invalidation
            },
            child: Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Function to reauthenticate the user and proceed with deletion
  static Future<void> confirmAndDeleteLogBook(BuildContext mainContext) async {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Enter Password to Confirm the deletion'),
        content: TextField(
          controller: passwordController,
          obscureText: true,  // Visible for testing purposes
          enableInteractiveSelection: false,
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

                  // Debugging prints
                  print("Attempting reauthentication...");
                  if (user == null) {
                    print("User is not logged in.");
                    Fluttertoast.showToast(
                        msg: 'User is not logged in.',
                        toastLength: Toast.LENGTH_LONG);
                    return;
                  }

                  print("User email: ${user.email}");
                  

                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );

                  // Attempt to reauthenticate
                  await user.reauthenticateWithCredential(credential);
                  print("Reauthentication successful");

                  // Now show the loading dialog using the main context
                  _showLoadingDialog(mainContext);  
                  
                  // Proceed with the deletion of documents
                  await _deleteAllDocuments(mainContext);
                } catch (e) {
                  print("Reauthentication failed: $e");
                  Fluttertoast.showToast(
                      msg: 'Incorrect password or reauthentication failed.',
                      toastLength: Toast.LENGTH_LONG);
                }
              } else {
                print("Password field was empty.");
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
