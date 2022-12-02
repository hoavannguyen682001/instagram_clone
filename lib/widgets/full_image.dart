import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:photo_view/photo_view.dart';

import '../screens/chat/chat_screen.dart';

class FullImageScreen extends StatelessWidget {
  final String url;
  FullImageScreen({Key? key, required this.arguments, required this.url})
      : super(key: key);

  final ChatScreenArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(arguments.photoUrl,
                  errorListener: () => Image.asset(
                        'assets/images/img_not_available.jpeg',
                        color: greyColor,
                      )),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  arguments.username,
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }
}

// class FullImageInfo {
//   final String uId;
//   final String username;
//   final String photoUrl;
//   FullImageInfo(
//       {required this.uId, required this.username, required this.photoUrl});
// }
