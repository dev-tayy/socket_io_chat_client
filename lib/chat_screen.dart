import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    this.id,
    this.username,
    this.sentAt,
    this.message,
  });

  String id;
  String username;
  String sentAt;
  String message;

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json["id"],
        username: json["username"],
        sentAt: json["sentAt"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "sentAt": sentAt,
        "message": message,
      };
}

class ChatScreen extends StatefulWidget {
  final String username;
  const ChatScreen({
    Key key,
    @required this.username,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatModel> _messages = [];

  final bool _showSpinner = false;
  final bool _showVisibleWidget = false;
  final bool _showErrorIcon = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Socket socket;

  @override
  void initState() {
    try {
      socket =
          io("https://blooming-coast-89347.herokuapp.com/", <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false,
      });

      socket.connect();

      socket.on('connect', (data) {
        debugPrint('connected');
        print(socket.connected);
      });

      socket.on('message', (data) {
        var message = ChatModel.fromJson(data);
        setStateIfMounted(() {
          _messages.add(message);
        });
      });

      socket.onDisconnect((_) => debugPrint('disconnect'));
    } catch (e) {
      print(e);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Chat Screen'),
          backgroundColor: const Color(0xFF271160)),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFEAEFF2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    reverse: _messages.isEmpty ? false : true,
                    itemCount: 1,
                    shrinkWrap: false,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 10, right: 10, bottom: 3),
                        child: Column(
                          mainAxisAlignment: _messages.isEmpty
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _messages.map((message) {
                                  print(message);
                                  return ChatBubble(
                                    date: message.sentAt,
                                    message: message.message,
                                    isMe: message.id == socket.id,
                                  );
                                }).toList()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Padding(
              //   padding: _newMessages.length != 0
              //       ? model.user.id == _newMessages.last.senderId
              //           ? const EdgeInsets.only(right: 30, bottom: 3)
              //           : const EdgeInsets.only(left: 30, bottom: 3)
              //       : const EdgeInsets.all(0),
              //   child: Visibility(
              //     visible: _showVisibleWidget,
              //     child: Row(
              //       mainAxisAlignment: _newMessages.length != 0
              //           ? model.user.id == _newMessages.last.senderId
              //               ? MainAxisAlignment.end
              //               : MainAxisAlignment.start
              //           : MainAxisAlignment.center,
              //       children: [
              //         _showSpinner
              //             ? model.user.id != widget.offer.creator.id
              //                 ? Image.asset('assets/images/msgLoadingMe.gif',
              //                     width: 30, height: 30)
              //                 : Image.asset('assets/images/msgLoadingYou.gif',
              //                     width: 30, height: 30)
              //             : const SizedBox(),
              //         _showErrorIcon
              //             ? const Text("Couldn't send message. Retry",
              //                 style: TextStyle(color: Colors.red, fontSize: 10))
              //             : const SizedBox(),
              //         _showErrorIcon
              //             ? const Icon(Icons.error, color: Colors.red, size: 20)
              //             : const SizedBox(),
              //       ],
              //     ),
              //   ),
              // ),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    bottom: 10, left: 20, right: 10, top: 5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: TextField(
                          minLines: 1,
                          maxLines: 5,
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Type a message",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 43,
                      width: 42,
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xFF271160),
                        onPressed: () async {
                          if (_messageController.text.trim().isNotEmpty) {
                            String message = _messageController.text.trim();

                            socket.emit(
                                "message",
                                ChatModel(
                                        id: socket.id,
                                        message: message,
                                        username: widget.username,
                                        sentAt: DateTime.now()
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16))
                                    .toJson());

                            _messageController.clear();
                          }
                        },
                        mini: true,
                        child: Transform.rotate(
                            angle: 5.79449,
                            child: const Icon(Icons.send, size: 20)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String date;

  ChatBubble({
    Key key,
    this.message,
    this.isMe = true,
    this.date,
  });
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            constraints: BoxConstraints(maxWidth: size.width * .5),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE3D8FF) : const Color(0xFFFFFFFF),
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(11),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                      bottomLeft: Radius.circular(0),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message ?? '',
                  textAlign: TextAlign.start,
                  softWrap: true,
                  style:
                      const TextStyle(color: Color(0xFF2E1963), fontSize: 14),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      date ?? '',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: Color(0xFF594097), fontSize: 9),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
