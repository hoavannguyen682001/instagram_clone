import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/widgets/full_image.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:intl/intl.dart';

import '../../resources/message_methods.dart';
import '../../utils/utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.arguments}) : super(key: key);

  final ChatScreenArguments arguments;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = false;
  bool isShowSticker = false;

  List<QueryDocumentSnapshot> listMessage = [];
  String groupChatId = '';
  String peerId = '';
  int _limit = 20;

  TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  Uint8List? _messageFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    readLocal();
    listScrollController.addListener(_scrollListener);
  }
  

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += 20;
      });
    }
  }

  void readLocal() {
    String peerId = widget.arguments.peerId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId - $peerId';
    } else {
      groupChatId = '$peerId - $currentUserId';
    }

    ChatProvider()
        .updateDataFirestore('user', currentUserId, {'chattingWith': peerId});
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      ChatProvider().sendMessage(
          content, type, groupChatId, currentUserId, widget.arguments.peerId);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      showSnackBar('Nothing to send', context);
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future getImage() async {
    Uint8List file = await pickImage(
      ImageSource.gallery,
    );
    if (file != null) {
      _messageFile = file;
      if (_messageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void clearImage() {
    setState(() {
      _messageFile = null;
    });
  }

  void uploadFile() async {
    try {
      String imageUrl = await ChatProvider().uploadImage(_messageFile!);
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(
                widget.arguments.photoUrl,
                errorListener: () => const Icon(
                  Icons.person,
                  color: Colors.red,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  widget.arguments.username,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                _buildListMessage(context),

                //Show Sticker
                isShowSticker ? _buildSticker() : SizedBox.shrink(),
              ],
            ),
            Positioned(
              child: isLoading
                  ? Center(child: LoadingView(context))
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildInput(),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('uidFrom') == currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('uidFrom') != currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildItem(int index, DocumentSnapshot? snapshot) {
    if (snapshot != null) {
      MessageChat messageChat = MessageChat.fromSnap(snapshot);
      if (messageChat.uidFrom == currentUserId) {
        //my message -> right
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            messageChat.type == TypeMessage.text
                ? Container(
                    // text message
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 8, right: 10),
                    child: Text(
                      messageChat.content,
                      style: TextStyle(color: primaryColor),
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    ? Container(
                        padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
                        // image message
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FullImageScreen(
                                    arguments: widget.arguments, url: messageChat.content,)));
                          },
                          child: Material(
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: greyColor2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: greyColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) =>
                                  Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ),
                      )
                    : Container(
                        // sticker
                        child: Image.asset(
                          'assets/image_gif/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                      )
          ],
        );
      } else {
        // Peer message -> left
        return Container(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  isLastMessageLeft(index)
                      ? Container(
                          margin: EdgeInsets.only(bottom: 3),
                          color: mobileBackgroundColor,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: CachedNetworkImageProvider(
                              widget.arguments.photoUrl,
                              errorListener: () => Icon(
                                Icons.account_circle,
                                size: 35,
                                color: greyColor,
                              ),
                            ),
                          ),
                        )
                      : Container(width: 36),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(
                                width: 2,
                                style: BorderStyle.solid,
                                color: Colors.white12),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          margin: EdgeInsets.only(left: 10),
                          child: Text(messageChat.content),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 15, 5),
                              child: InkWell(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => FullImageScreen(
                                        arguments: widget.arguments, url: messageChat.content,)));
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: greyColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              child: Image.asset(
                                'assets/image_gif/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(left: 10),
                            )
                ],
              ),
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(messageChat.timestamp),
                          ),
                        ),
                        style: TextStyle(
                            color: greyColor,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                      margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
                    )
                  : SizedBox.shrink()
            ],
          ),
          margin: EdgeInsets.only(bottom: 8),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildListMessage(BuildContext context) {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: ChatProvider().getChatStream(groupChatId, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          _buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(child: Text("No message here yet..."));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildSticker() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 0.5,
            color: primaryColor,
          ),
        ),
      ),
      height: 200,
      padding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => onSendMessage('mimi1', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi1.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi2.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi3.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => onSendMessage('mimi4', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi4.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi5.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi6.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => onSendMessage('mimi7', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi7.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi8.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/image_gif/mimi9.gif',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      height: kToolbarHeight,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Row(
        children: [
          Material(
            color: mobileBackgroundColor,
            child: IconButton(
              iconSize: 30,
              padding: EdgeInsets.all(4),
              icon: Icon(Icons.image),
              onPressed: getImage,
            ),
          ),
          Material(
            color: mobileBackgroundColor,
            child: IconButton(
              iconSize: 30,
              padding: EdgeInsets.all(4),
              icon: Icon(Icons.gif_box_outlined),
              onPressed: getSticker,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 2),
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, TypeMessage.text);
                },
                style: TextStyle(color: primaryColor),
                controller: textEditingController,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  hintText: 'Type your message... ',
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.all(12),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            color: mobileBackgroundColor,
            child: Container(
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, TypeMessage.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreenArguments {
  final String peerId;
  final String username;
  final String photoUrl;
  ChatScreenArguments(
      {required this.peerId, required this.username, required this.photoUrl});
}
