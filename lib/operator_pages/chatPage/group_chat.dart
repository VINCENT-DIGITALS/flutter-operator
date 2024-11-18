import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../components/group_setting.dart';
import '../../components/groupchat_header.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/appbar_navigation.dart';

class GroupChatPage extends StatefulWidget {
  final String chatId;
  final String gChatname;

  const GroupChatPage({Key? key, required this.chatId, required this.gChatname})
      : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _dbService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _limit = 10;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        isLargeScreen: isLargeScreen,
        scaffoldKey: _scaffoldKey,
        title: widget.gChatname,
        onSettingsPress: () => openSettings(context, widget.chatId),
      ),
      drawer: isLargeScreen
          ? null
          : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/chat'),
      body: Row(
        children: [
          // CustomDrawer for large screen
          if (isLargeScreen)
            Container(
              width: 250,
              child: CustomDrawer(
                scaffoldKey: _scaffoldKey,
                currentRoute: '/chat',
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels ==
                          notification.metrics.minScrollExtent) {
                        _loadMoreMessages();
                        return true;
                      }
                      return false;
                    },
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          _dbService.getMessages(widget.chatId, limit: _limit),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var messages = snapshot.data!.docs;
                        return ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var messageData = messages[index];
                            var message = messageData['message'];
                            var senderRef =
                                messageData['sender'] as DocumentReference;
                            var timestamp = messageData['timestamp'].toDate();
                            var formattedTime =
                                DateFormat('hh:mm a').format(timestamp);
                            String currentUserId =
                                _dbService.getCurrentUserId() ?? '';
                            bool isMe = senderRef.id == currentUserId;
                            var displayName =
                                messageData['displayName'] ?? 'Unknown';

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6.0, horizontal: 12.0),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Text(
                                          displayName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.blueAccent
                                            : Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        formattedTime,
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _isSending = true;
      });

      String? userId = _dbService.getCurrentUserId();
      if (userId != null) {
        await _dbService.sendMessage(
          widget.chatId,
          _messageController.text,
          userId,
          false,
        );
        _messageController.clear();
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        print("User is not logged in");
      }

      setState(() {
        _isSending = false;
      });
    }
  }

  void _loadMoreMessages() {
    setState(() {
      _limit += 10;
    });
  }
}
