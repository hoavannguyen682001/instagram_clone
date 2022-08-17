import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String caption;
  final String username;
  final String uid;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;
  final likes;

  Post(
      {required this.caption,
        required this.username,
        required this.uid,
        required this.postId,
        required this.datePublished,
        required this.postUrl,
        required this.profImage,
        required this.likes
      });

  Map<String, dynamic> toJson() =>{
    "username": username,
    "caption": caption,
    "uid": uid,
    "postId": postId,
    "datePublished": datePublished,
    "postUrl": postUrl,
    "profImage": profImage,
    "likes": likes,
  };

  static Post fromSnap(DocumentSnapshot snap){
    var snapShot = snap.data() as Map<String, dynamic>;

    return Post(
      username: snapShot['username'],
      caption: snapShot['email'],
      uid: snapShot['uid'],
      postId: snapShot['bio'],
      datePublished: snapShot['photoUrl'],
      postUrl: snapShot['followers'],
      profImage: snapShot['following'],
      likes: snapShot['likes'],
    );

  }

}
