import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class ChatProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) async {
    String res = 'Some error occurred';
    try {
      MessageChat messageChat = MessageChat(
          uidFrom: currentUserId,
          uidTo: peerId,
          timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          type: type);

      _firestore
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(messageChat.toJson());

      res = 'Success';
    } on FirebaseException catch (err) {
      res = err.toString();
    }
    return res;
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return _firestore
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<String> uploadImage(Uint8List file) async {
    String messageImage =
        await StorageMethods().uploadImageToStorage('messages', file, true);
    return messageImage;
  }

  Future<void> updateDataFirestore(
      String collectionPath, String uid, Map<String, dynamic> dataNeedUpdate) {
    return _firestore
        .collection(collectionPath)
        .doc(uid)
        .update(dataNeedUpdate);
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
