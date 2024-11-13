import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/appbar_navigation.dart';
import '../../widgets/custom_drawer.dart';
import 'group_chat.dart';

class ChatListPage extends StatefulWidget {
  final String currentPage;

  const ChatListPage({super.key, this.currentPage = 'group_chat'});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _createNewChat() async {
    final TextEditingController _chatNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Group Chat Name'),
          content: TextField(
            controller: _chatNameController,
            decoration: InputDecoration(hintText: "Group Chat Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_chatNameController.text.isNotEmpty) {
                  await _addChatToFirestore(_chatNameController.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addChatToFirestore(String chatName) async {
    await chats.add({
      'chat_name': chatName,
      'last_message': '',
      'last_message_seen_by': null,
      'last_message_sent_by': null,
      'last_message_time': FieldValue.serverTimestamp(),
      'owner': FirebaseFirestore.instance.doc('/operator/${currentUser!.uid}'),
      'participants': [
        FirebaseFirestore.instance.doc('/operator/${currentUser!.uid}')
      ],
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        isLargeScreen: isLargeScreen,
        scaffoldKey: _scaffoldKey,
        title: 'Group Chat',
      ),
      drawer: isLargeScreen
          ? null
          : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/group_chat'),
      body: Row(
        children: [
          if (isLargeScreen)
            Container(
              width: 250,
              child: CustomDrawer(
                scaffoldKey: _scaffoldKey,
                currentRoute: '/group_chat',
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chats.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var chatDocs = snapshot.data!.docs;

                var filteredChats = chatDocs.where((doc) {
                  var participants = doc['participants'] as List<dynamic>;
                  return participants.any((participant) {
                    return participant.toString().contains(currentUser!.uid);
                  });
                }).toList();

                if (filteredChats.isEmpty) {
                  return Center(child: Text('No chat Available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    var chatData = filteredChats[index];
                    var lastMessage = chatData['last_message'];
                    var lastMessageTime = chatData['last_message_time']?.toDate();
                    var chatTitle = chatData['chat_name'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            chatTitle[0],
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          radius: 25,
                        ),
                        title: Text(
                          chatTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: lastMessageTime != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${lastMessageTime.hour}:${lastMessageTime.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupChatPage(chatId: chatData.id, gChatname: chatTitle),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
