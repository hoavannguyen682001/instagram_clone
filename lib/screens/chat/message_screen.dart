import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:instagram_clone/screens/chat/chat_screen.dart';
import 'package:instagram_clone/screens/profile/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

import '../../models/user.dart' as model;
import '../../utils/utils.dart';

class MessageScreen extends StatefulWidget {
  String uid;
  MessageScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String auth = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  //Controller Search
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  //Controller ListView
  final ScrollController listScrollController = ScrollController();
  int _limit = 15;

  var userData = {};

  static final customCache = CacheManager(
    Config('customCacheKey',
        stalePeriod: Duration(days: 7), maxNrOfCacheObjects: 50),
  );

  @override
  void initState() {
    super.initState();
    getData();
    listScrollController.addListener(scrollListener);
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;

      setState(() {});
    } on Exception catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += 15;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username']),
              actions: [
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    _buildSearchBar(context),
                    Container(
                      margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      alignment: Alignment.centerLeft,
                      child: Text('Message'),
                    ),
                    Expanded(
                      child: isShowUsers
                          ? FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('user')
                                  .orderBy('username')
                                  .startAt([searchController.text])
                                  .endAt(
                                  [searchController.text + '\uf8ff'])
                                  // .where('username',
                                  //     isGreaterThanOrEqualTo:
                                  //         searchController.text)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ListView.builder(
                                  itemCount:
                                      (snapshot.data! as dynamic).docs.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        model.User user = model.User.fromSnap(
                                            (snapshot.data! as dynamic)
                                                .docs[index]);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              arguments: ChatScreenArguments(
                                                peerId: user.uid,
                                                username: user.username,
                                                photoUrl: user.photoUrl,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  (snapshot.data! as dynamic)
                                                      .docs[index]['photoUrl'],
                                                  cacheManager: customCache),
                                        ),
                                        title: Text((snapshot.data! as dynamic)
                                            .docs[index]['username']),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('user')
                                  .limit(_limit)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      controller: listScrollController,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        return _buildItem(context,
                                            snapshot.data!.docs[index]);
                                      });
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mobileSearchColor,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
      child: TextFormField(
        textInputAction: TextInputAction.search,
        controller: searchController,
        decoration: const InputDecoration(
            isCollapsed: true,
            hintText: 'Search for a user',
            hintStyle: TextStyle(color: greyColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12)),
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
    );
  }

  Widget _buildItem(BuildContext context, DocumentSnapshot? snapshot) {
    if (snapshot != null) {
      model.User user = model.User.fromSnap(snapshot);
      if (user.uid == auth) {
        return SizedBox.shrink();
      } else {
        return Container(
          margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white12),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              )),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    arguments: ChatScreenArguments(
                        peerId: user.uid,
                        username: user.username,
                        photoUrl: user.photoUrl),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      user.photoUrl,
                      cacheManager: customCache,
                      errorListener: () => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}

// loadingBuilder: (BuildContext context, Widget child,
// ImageChunkEvent? loadingProgress) {
// if (loadingProgress == null)
// return child;
// else {
// return CircularProgressIndicator(
// value: loadingProgress.expectedTotalBytes != null
// ? loadingProgress.cumulativeBytesLoaded /
// loadingProgress.expectedTotalBytes!
//     : null,
// );
// }
// },
// errorBuilder: (context, object, stackTrace) {
// return const Icon(
// Icons.account_circle,
// size: 50,
// color: Colors.grey,
// );
// },
