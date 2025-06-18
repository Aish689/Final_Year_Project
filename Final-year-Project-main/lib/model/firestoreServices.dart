import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soricc/model/message.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get messages
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  // Send a message
  Future<void> sendMessage(
      String chatRoomId, Message message, String adminToken) async {
    try {
      final docRef = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());
      // Update message ID with the generated Firestore document ID
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Update typing status
  Future<void> updateTypingStatus(
      String chatRoomId, bool isTyping, String userId) async {
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'typingStatus': {userId: isTyping},
    });
  }

  // Update message status
  Future<void> updateMessageStatus(
      String chatRoomId, String messageId, String statusField) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({statusField: true});
    } catch (e) {
      print('Error updating message status: $e');
    }
  }

  // Update user presence
  Future<void> updateUserPresence(bool isOnline, String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': isOnline ? null : Timestamp.now(),
    });
  }
Stream<List<Map<String, dynamic>>> fetchAnnouncements() {
  return _firestore.collection("anouncements").snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      // Convert Firestore Timestamp to readable format
      Timestamp? timestampTime = doc["time"] is Timestamp ? doc["time"] : null;
      Timestamp? timestampDate = doc["date"] is Timestamp ? doc["date"] : null;

      return {
        "title": doc["title"] ?? "No Title",
        "content": doc["content"] ?? "No Content",
        "time": timestampTime != null 
            ? "${timestampTime.toDate().hour}:${timestampTime.toDate().minute}" 
            : "No Time",
        "date": timestampDate != null 
            ? "${timestampDate.toDate().day}/${timestampDate.toDate().month}/${timestampDate.toDate().year}" 
            : "No Date",
      };
    }).toList();
  });
}

}
