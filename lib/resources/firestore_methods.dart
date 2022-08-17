import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';

class FireStoreMethods {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String caption,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = 'Some error occurred';
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
          caption: caption,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          likes: []);

      _fireStore.collection('posts').doc(postId).set(post.toJson());
      res = 'Success';
    } on FirebaseException catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _fireStore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _fireStore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid,
      String username, String profPic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = Uuid().v1();
        _fireStore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'commentId': commentId,
          'comment': text,
          'uid': uid,
          'username': username,
          'profPic': profPic,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      _fireStore.collection('posts').doc(postId).delete();
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
   DocumentSnapshot snapshot = await _fireStore.collection('user').doc(uid).get();
   List following = (snapshot.data()! as dynamic)['following'];

   try {
     if(following.contains(followId)){
       _fireStore.collection('user').doc(followId).update({
         'followers' : FieldValue.arrayRemove([uid])
       });

       _fireStore.collection('user').doc(uid).update({
         'following' : FieldValue.arrayRemove([followId])
       });
     }else{
       _fireStore.collection('user').doc(followId).update({
         'followers' : FieldValue.arrayUnion([uid])
       });

       _fireStore.collection('user').doc(uid).update({
         'following' : FieldValue.arrayUnion([followId])
       });
     }
   } on Exception catch (e) {
     print(e.toString());
   }

  }
}
