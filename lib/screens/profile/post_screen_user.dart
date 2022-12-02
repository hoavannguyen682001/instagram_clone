import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/colors.dart';
import '../../utils/global_variables.dart';
import '../../widgets/post_card.dart';

class PostScreenUser extends StatefulWidget {
  const PostScreenUser({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  State<PostScreenUser> createState() => _PostScreenUserState();
}

class _PostScreenUserState extends State<PostScreenUser> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
      width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text('Post')
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            // .orderBy('datePublished', descending: true)
            .where('uid', isEqualTo: widget.uid)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: width > webScreenSize
                            ? MediaQuery.of(context).size.width * 0.3
                            : 0,
                        vertical: width > webScreenSize ? 12 : 0),
                    child: PostCard(snap: snapshot.data?.docs[index].data())));

          } else {
            return const Center(
              child: Text('No data'),
            );

          }

        },
      ),
    );
  }
}
