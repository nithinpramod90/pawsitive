import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawsitive/model/popup_menu_model.dart';
import 'package:pawsitive/screens/chat/chat_conversation_screen.dart';
import 'package:pawsitive/services/firebase_services.dart';

class ChatCard extends StatefulWidget {
  final Map<String, dynamic> chatData;
  const ChatCard(this.chatData, {super.key});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final FirebaseService _service = FirebaseService();
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  late DocumentSnapshot doc;
  String lastChatData = '';

  @override
  void initState() {
    getChatTime();
    getProductDetails();
    super.initState();
  }

  getProductDetails() {
    _service.getProductDetails(widget.chatData['product']['productId']).then((value) {
      setState(() {
        doc = value;
      });
    });
  }

  getChatTime() {
    var date = DateFormat.yMMMd().format(DateTime.fromMicrosecondsSinceEpoch(widget.chatData['lastChatTime']));
    var today = DateFormat.yMMMd().format(DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch));
    if (date == today) {
      setState(() {
        lastChatData = 'Today';
      });
    } else {
      setState(() {
        lastChatData = date.toString();
      });
    }
  }

  List<PopupMenuModel> menuItems = [
    PopupMenuModel('Delete chat', Icons.delete),
    PopupMenuModel('Mark as sold', Icons.done),
  ];
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Stack(
        children: [
          const SizedBox(
            height: 18,
          ),
          ListTile(
            onTap: () {
              _service.messages.doc(widget.chatData['chatRoomId']).update({
                'read': true,
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ChatConversations(
                            chatRoomId: widget.chatData['chatRoomId'],
                          )));
            },
            shape: const Border(bottom: BorderSide(color: Colors.grey)),
            leading: SizedBox(height: 60, width: 60, child: Image.network(doc['images'][0])),
            title: Text(
              doc['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['description'],
                  maxLines: 1,
                ),
              ],
            ),
            trailing: CustomPopupMenu(
              menuBuilder: () => ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: const Color(0xFF4C4C4C),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: menuItems
                          .map(
                            (item) => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (item.title == 'Delete chat') {
                                  _service.deleteChat(widget.chatData['chatRoomId']);
                                }
                                _controller.hideMenu();
                              },
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      item.icon,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              pressType: PressType.singleClick,
              verticalMargin: -10,
              controller: _controller,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Icon(Icons.more_vert_outlined, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
