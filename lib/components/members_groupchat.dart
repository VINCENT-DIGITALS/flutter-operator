import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ParticipantsFloatingWidget extends StatelessWidget {
  final String chatId;

  const ParticipantsFloatingWidget({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference chats = FirebaseFirestore.instance.collection('chats');
    final User? currentUser = FirebaseAuth.instance.currentUser; // Get current user

    return FutureBuilder<DocumentSnapshot>(
      future: chats.doc(chatId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var chatData = snapshot.data!;
        var participants = chatData['participants'] as List<dynamic>; // List of DocumentReferences to users
        var ownerRef = chatData['owner'] as DocumentReference; // Owner of the chat

        // Determine if the current user is the owner of the chat
        var currentUserOperatorId = FirebaseFirestore.instance.doc('/operator/${currentUser?.uid}');
        bool isOwner = ownerRef == currentUserOperatorId;

        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Group Participants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    // Get each participant's DocumentReference
                    var participantRef = participants[index] as DocumentReference;

                    // Fetch participant's data
                    return FutureBuilder<DocumentSnapshot>(
                      future: participantRef.get(),
                      builder: (context, participantSnapshot) {
                        if (!participantSnapshot.hasData) {
                          return ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        var participantData = participantSnapshot.data!;
                        String displayName = participantData['displayName'] ?? 'Unknown User';
                        bool isCurrentParticipantOwner = participantRef == ownerRef;

                        return ListTile(
                          title: Text(displayName),
                          subtitle: isCurrentParticipantOwner ? Text('Owner') : null,
                          leading: Icon(Icons.person),
                          trailing: isOwner && !isCurrentParticipantOwner
                              ? IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    // Show confirmation dialog before removing participant
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Remove Participant'),
                                          content: Text('Are you sure you want to remove $displayName from the group?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context); // Close the dialog
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Remove the participant from the group
                                                chats.doc(chatId).update({
                                                  'participants': FieldValue.arrayRemove([participantRef])
                                                }).then((value) {
                                                  Fluttertoast.showToast(
                                                      msg: '$displayName has been removed from the group');
                                                  Navigator.pop(context); // Close the dialog after removing
                                                }).catchError((error) {
                                                  Fluttertoast.showToast(
                                                      msg: 'Failed to remove user: $error');
                                                });
                                              },
                                              child: Text('Remove'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              : null, // Hide the icon if the user is not the owner or if the participant is the owner
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
