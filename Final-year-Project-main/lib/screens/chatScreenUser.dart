import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soricc/model/firestoreServices.dart';
import 'package:soricc/model/message.dart';

class UserChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String userName;

  UserChatScreen({required this.chatRoomId, required this.userName});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  User? currentUser;
  bool isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    firestoreService.updateUserPresence(
        true, FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void dispose() {
    firestoreService.updateUserPresence(
        false, FirebaseAuth.instance.currentUser!.uid);
    messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            SizedBox(width: 10),
            Text(
              widget.userName,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: firestoreService.getMessages(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No chats yet. Start the conversation!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByUser = message.senderId == currentUser?.uid;

                    if (!isSentByUser && !message.isRead) {
                      firestoreService.updateMessageStatus(
                          widget.chatRoomId, message.id, 'isRead');
                    }

                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.deepPurple
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isSentByUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              onChanged: (text) {
                firestoreService.updateTypingStatus(widget.chatRoomId,
                    text.isNotEmpty, currentUser?.uid ?? "unknown");
              },
              decoration: InputDecoration(
                hintText: "Type a message...",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            icon: isSendingMessage
                ? CircularProgressIndicator(color: Colors.deepPurple)
                : Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                final messageText = messageController.text;
                messageController.clear();

                final newMessage = Message(
                  id: '', // Firestore generates this ID
                  senderId: currentUser?.uid ?? "unknown",
                  text: messageText,
                  timestamp: DateTime.now(),
                );

                setState(() {
                  isSendingMessage = true;
                });

                await firestoreService.sendMessage(
                  widget.chatRoomId,
                  newMessage,
                  'ADMIN_FCM_TOKEN', // Replace with admin token retrieval logic
                );

                firestoreService.updateTypingStatus(
                    widget.chatRoomId, false, currentUser?.uid ?? "unknown");

                setState(() {
                  isSendingMessage = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    return currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        'User';
  }
}