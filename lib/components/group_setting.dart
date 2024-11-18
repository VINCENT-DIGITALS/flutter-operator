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
          var chatName = chatData['chat_name']; // Current chat name

          var currentUserOperatorId = FirebaseFirestore.instance.doc('/operator/${currentUser?.uid}');
          bool isOwner = ownerRef == currentUserOperatorId; // Check if current user is the owner

          return FutureBuilder<QuerySnapshot>(
            future: responders.get(),
            builder: (context, responderSnapshot) {
              if (!responderSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var responderDocs = responderSnapshot.data!.docs;

              return StatefulBuilder(
                builder: (context, setState) {
                  bool isLoading = false; // Loading state for actions

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
                              TextEditingController chatNameController = TextEditingController(text: chatName);

                              showDialog(
                                context: context,
                                builder: (context) {
                                  bool isUpdating = false; // State for updating the chat name

                                  return StatefulBuilder(
                                    builder: (context, setDialogState) {
                                      return AlertDialog(
                                        title: Text('Change Chat Name'),
                                        content: TextField(
                                          controller: chatNameController,
                                          decoration: InputDecoration(hintText: 'Enter new chat name'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: isUpdating
                                                ? null
                                                : () async {
                                                    setDialogState(() => isUpdating = true);

                                                    try {
                                                      await chats.doc(chatId).update({
                                                        'chat_name': chatNameController.text,
                                                      });
                                                      Fluttertoast.showToast(msg: 'Chat name updated');
                                                      Navigator.pop(context); // Close the dialog after updating
                                                    } catch (e) {
                                                      Fluttertoast.showToast(msg: 'Error updating chat name: $e');
                                                    } finally {
                                                      setDialogState(() => isUpdating = false);
                                                    }
                                                  },
                                            child: isUpdating
                                                ? SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : Text('Update'),
                                          ),
                                        ],
                                      );
                                    },
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

                                      return StatefulBuilder(
                                        builder: (context, setTileState) {
                                          bool isAdding = false; // State for adding participant

                                          return ListTile(
                                            title: Text(responderData['displayName']), // Assuming responders have 'displayName'
                                            trailing: isAdding
                                                ? SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : participants.contains(responderDocRef)
                                                    ? Text('Already in group', style: TextStyle(color: Colors.grey))
                                                    : Icon(Icons.add),
                                            onTap: participants.contains(responderDocRef) || isAdding
                                                ? null
                                                : () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text('Add Participant'),
                                                          content: Text(
                                                              'Are you sure you want to add ${responderData['displayName']} to the group?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: Text('Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                Navigator.pop(context); // Close confirmation dialog
                                                                setTileState(() => isAdding = true);

                                                                try {
                                                                  await chats.doc(chatId).update({
                                                                    'participants':
                                                                        FieldValue.arrayUnion([responderDocRef])
                                                                  });
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          '${responderData['displayName']} has been added to the group');
                                                                } catch (e) {
                                                                  Fluttertoast.showToast(
                                                                      msg: 'Failed to add user: $e');
                                                                } finally {
                                                                  setTileState(() => isAdding = false);
                                                                }
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
    },
  );
}
