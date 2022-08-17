import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;
  CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CommentCardState();
  }
}

class _CommentCardState extends State<CommentCard> {


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
                widget.snap['profPic']),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['username'] + ' ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextSpan(
                          text: widget.snap['comment'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snap['datePublished'].toDate(),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.favorite_outline,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
