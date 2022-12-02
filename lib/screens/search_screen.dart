import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile/post_screen_user.dart';
import 'package:instagram_clone/screens/profile/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/post_card.dart';

import '../models/post.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user',
            border: InputBorder.none,
          ),
          onFieldSubmitted: (String _) {
            setState(() {
              if (searchController.text.isNotEmpty) {
                isShowUsers = true;
              } else {
                isShowUsers = false;
              }
            });
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .orderBy('username')
                  .startAt([searchController.text]).endAt(
                      [searchController.text + '\uf8ff'])
                  // .where('username',
                  //     isGreaterThanOrEqualTo: searchController.text)
                  // .where('username', isLessThanOrEqualTo: searchController.text + 'z')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              (snapshot.data! as dynamic).docs[index]
                                  ['photoUrl']),
                        ),
                        title: Text((snapshot.data! as dynamic).docs[index]
                            ['username']),
                      ),
                    );
                  },
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('posts').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                    return MasonryGridView.builder(
                      gridDelegate:
                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          screenWidth > webScreenSize ? 3 : 2),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return _ImageItem(context, snapshot.data!.docs[index]);
                      },
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 6,
                    );
                },
              ),
            ),
    );
  }

  Widget _ImageItem(BuildContext context, DocumentSnapshot? snapshot) {
    if (snapshot != null) {
      // Post post = Post.fromSnap(snapshot);
      return Container(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PostScreenUser(
                      uid: snapshot['uid'],
                    )));
          },
          child: Material(
            child: CachedNetworkImage(
              imageUrl: snapshot['postUrl'],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
