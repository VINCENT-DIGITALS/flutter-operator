import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'members_groupchat.dart';

void openSettings(BuildContext context, String chatId) {
  final CollectionReference responders = FirebaseFirestore.instance.collection('responders');
  final CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final User? currentUser = FirebaseAuth.instance.currentUser; // Get current user

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return FutureBuilder<DocumentSnapshot>(
        future: chats.doc(chatId).get(),
        builder: (context, chatSnapshot) {
          if (!chatSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var chatData = chatSnapshot.data!;
          var participants = chatData['participants'] as List<dynamic>; // List of DocumentReferences
          var ownerRef = chatData['owner'] as DocumentReference; // Owner of the chat
          var chatName = chatData['chat_name']; // Get current chat name

          var currentUserOperatorId = FirebaseFirestore.instance.doc('/operator/${currentUser?.uid}'); // DocumentReference for current user
          bool isOwner = ownerRef == currentUserOperatorId; // Check if current user is owner

          return FutureBuilder<QuerySnapshot>(
            future: responders.get(),
            builder: (context, responderSnapshot) {
              if (!responderSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var responderDocs = responderSnapshot.data!.docs;

              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text('See Members'),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ParticipantsFloatingWidget(chatId: chatId);
                          },
                        );
                      },
                    ),
                    if (isOwner)
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Change Chat Name'),
                        onTap: () {
                          // Dialog for changing chat name
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController chatNameController = TextEditingController(text: chatName);

                              return AlertDialog(
                                title: Text('Change Chat Name'),
                                content: TextField(
                                  controller: chatNameController,
                                  decoration: InputDecoration(hintText: 'Enter new chat name'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Update chat name in Firestore
                                      chats.doc(chatId).update({
                                        'chat_name': chatNameController.text,
                                      }).then((value) {
                                        Fluttertoast.showToast(msg: 'Chat name updated');
                                        Navigator.pop(context); // Close the dialog after updating
                                      }).catchError((error) {
                                        Fluttertoast.showToast(msg: 'Failed to update chat name: $error');
                                      });
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    if (isOwner)
                      ListTile(
                        leading: Icon(Icons.person_add),
                        title: Text('Add User'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ListView.builder(
                                itemCount: responderDocs.length,
                                itemBuilder: (context, index) {
                                  var responderData = responderDocs[index];
                                  var responderId = responderData.id;

                                  var responderDocRef = responders.doc(responderId);

                                  return ListTile(
                                    title: Text(responderData['displayName']), // Assuming responders have a 'displayName' field
                                    trailing: participants.contains(responderDocRef)
                                        ? Text('Already in group', style: TextStyle(color: Colors.grey))
                                        : Icon(Icons.add),
                                    onTap: participants.contains(responderDocRef)
                                        ? null
                                        : () {
                                            // Show confirmation dialog before adding participant
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Add Participant'),
                                                  content: Text(
                                                      'Are you sure you want to add ${responderData['displayName']} to the group?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Add the responder to the group
                                                        chats.doc(chatId).update({
                                                          'participants': FieldValue.arrayUnion([responderDocRef])
                                                        }).then((value) {
                                                          Fluttertoast.showToast(
                                                              msg: '${responderData['displayName']} has been added to the group');
                                                          Navigator.pop(context); // Close the dialog after adding
                                                        }).catchError((error) {
                                                          Fluttertoast.showToast(
                                                              msg: 'Failed to add user: $error');
                                                        });
                                                      },
                                                      child: Text('Add'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
