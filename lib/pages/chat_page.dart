import 'dart:io';

import 'package:flutter/material.dart';
import 'camera.dart';

class Message {
  final String? text;
  final File? image;

  Message({this.text, this.image});
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendTextMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(Message(text: _controller.text.trim()));
      _controller.clear();
    });
  }

  Future<void> _sendImageMessage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          onImageCaptured: (File image) {
            setState(() {
              _messages.add(Message(image: image));
            });
          },
        ),
      ),
    );
  }

  Widget _buildMessage(Message message) {
    if (message.image != null) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(message.image!, height: 200),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFA5D6A7),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          message.text ?? "",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🌿 GreenChat"),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
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
                        hintText: "Ketik pesan...",
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
