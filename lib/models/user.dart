import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String username;
  final String uid;
  final String bio;
  final String photoUrl;
  final List followers;
  final List following;

  User(
      {required this.email,
      required this.username,
      required this.uid,
      required this.bio,
      required this.photoUrl,
      required this.followers,
      required this.following});

  Map<String, dynamic> toJson() =>{
    "username": username,
    "email": email,
    "uid": uid,
    "bio": bio,
    "photoUrl": photoUrl,
    "followers": followers,
    "following": following,
  };

  static User fromSnap(DocumentSnapshot snap){
    var snapShot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapShot['username'],
      email: snapShot['email'],
      uid: snapShot['uid'],
      bio: snapShot['bio'],
      photoUrl: snapShot['photoUrl'],
      followers: snapShot['followers'],
      following: snapShot['following'],
    );

  }

}
