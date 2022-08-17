import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetail() async{
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    return model.User.fromSnap(snap);
  }

  //sign up user
  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List file}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
            email: email,
            username: username,
            uid: cred.user!.uid,
            bio: bio,
            photoUrl: photoUrl,
            followers: [],
            following: []);

        //add user to database
        await _firestore.collection('user').doc(cred.user!.uid).set(user.toJson());
        res = 'Success';
      }
    } on FirebaseAuthException catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Login user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = 'Some error occurred';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }
}
