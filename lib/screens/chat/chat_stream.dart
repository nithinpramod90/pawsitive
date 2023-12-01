// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:pawsitive/services/firebase_services.dart';

class ChatStream extends StatefulWidget {
  final String chatRoomId;

  const ChatStream({super.key, required this.chatRoomId});

  @override
  State<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  // ignore: prefer_final_fields
  FirebaseService _service = FirebaseService();
  late Stream<QuerySnapshot> chatMessageStream;
  late DocumentSnapshot chatDoc;
  final bool _init = true;
  @override
  void initState() {
    _service.getchat(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    _service.messages.doc(widget.chatRoomId).get().then((value) {
      setState(() {
        chatDoc = value;
      });
    });
    chatMessageStream = FirebaseFirestore.instance.collection('chatMessages').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 60,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: chatMessageStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            );
          }

          return snapshot.hasData
              ? Column(
                  children: [
                    const SizedBox(
                      height: 14,
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chatDoc['product']['productImage']),
                      ),
                      title: Text(
                        chatDoc['product']['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade300,
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            String sentBy = snapshot.data!.docs[index]['sentBy'];
                            String me = _service.user!.uid;
                            String lastChatDate;
                            var _date = DateFormat.yMMMd().format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[index]['time']));
                            var _today = DateFormat.yMMMd().format(DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch));
                            if (_date == _today) {
                              lastChatDate = DateFormat('hh:mm').format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[index]['time']));
                            } else {
                              lastChatDate = _date.toString();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ChatBubble(
                                    alignment: sentBy == me ? Alignment.centerRight : Alignment.centerLeft,
                                    backGroundColor: sentBy == me ? Theme.of(context).primaryColor : Colors.grey,
                                    clipper: ChatBubbleClipper4(type: sentBy == me ? BubbleType.sendBubble : BubbleType.receiverBubble),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                                      ),
                                      child: Text(
                                        snapshot.data!.docs[index]['message'],
                                        style: TextStyle(color: sentBy == me ? Colors.white : Colors.black),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: sentBy == me ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Text(
                                      lastChatDate,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Container();
        },
      ),
    );
  }
}
