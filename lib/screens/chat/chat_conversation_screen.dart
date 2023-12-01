import 'package:flutter/material.dart';
import 'package:pawsitive/screens/chat/chat_stream.dart';
import 'package:pawsitive/services/firebase_services.dart';

class ChatConversations extends StatefulWidget {
  final String chatRoomId;
  const ChatConversations({super.key, required this.chatRoomId});

  @override
  State<ChatConversations> createState() => _ChatConversationsState();
}

class _ChatConversationsState extends State<ChatConversations> {
  final FirebaseService _service = FirebaseService();

  var chatMessageController = TextEditingController();
  bool _send = false;

  sendMessage() {
    if (chatMessageController.text.isNotEmpty) {
      Map<String, dynamic> message = {
        'message': chatMessageController.text,
        'sentBy': _service.user!.uid,
        'time': DateTime.now().microsecondsSinceEpoch
      };
      _service.createChat(widget.chatRoomId, message);
      chatMessageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: avoid_unnecessary_containers
      body: Container(
        child: Stack(
          children: [
            ChatStream(
              chatRoomId: widget.chatRoomId,
            ),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade800),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: chatMessageController,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            hintText: 'Type Messages',
                            hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                _send = true;
                              });
                            } else {
                              setState(() {
                                _send = false;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              sendMessage();
                            }
                          },
                        ),
                      ),
                      Visibility(
                        visible: _send,
                        child: IconButton(
                          onPressed: () {
                            sendMessage();
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
