import 'dart:io';
import 'package:flutter/material.dart';
import 'camera.dart';

class Message {
  final String? text;
  final File? image;
  final bool isFromPartner;

  Message({this.text, this.image, this.isFromPartner = false});
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      _addMessage(Message(
        text: "Sayanggg 🤭",
        isFromPartner: true,
      ));
      Future.delayed(Duration(milliseconds: 500), () {
        _addMessage(Message(
          text: "Kamu lagi ngapain? Kirimin aku foto gantengmu dong~ 📸🥰",
          isFromPartner: true,
        ));
      });
    });
  }

  void _addMessage(Message message) {
    _messages.add(message);
    _listKey.currentState?.insertItem(_messages.length - 1);
  }

  void _sendTextMessage() {
    if (_controller.text.trim().isEmpty) return;
    _addMessage(Message(text: _controller.text.trim()));
    _controller.clear();
  }

  Future<void> _sendImageMessage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          onImageCaptured: (File image) {
            _addMessage(Message(image: image));
          },
        ),
      ),
    );
  }

  Widget _buildMessage(Message message, Animation<double> animation) {
    final isPartner = message.isFromPartner;
    final alignment = isPartner ? Alignment.centerLeft : Alignment.centerRight;
    final color = isPartner ? Colors.white : Color(0xFFA5D6A7);

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Align(
        alignment: alignment,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: message.image == null ? EdgeInsets.all(12) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: message.image == null ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (message.image == null)
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: message.image != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(message.image!, height: 200),
          )
              : Text(
            message.text ?? "",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("💬 MiChat"),
        backgroundColor: Color(0xFF2E7D32),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              padding: EdgeInsets.all(16),
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) =>
                  _buildMessage(_messages[index], animation),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
                  onPressed: _sendImageMessage,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF2E7D32), width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Balas...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF2E7D32)),
                  onPressed: _sendTextMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
