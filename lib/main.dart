import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(ChatBotApp());

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String sessionId = "12345";  // You can generate or manage session IDs as needed.

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    // Add user message to chat
    setState(() {
      _messages.add({"role": "user", "content": message});
    });

    _controller.clear();

    // Call the Flask API
    final response = await http.post(
      Uri.parse('https://33b8-63-143-118-227.ngrok-free.app/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'question': message,
        'session_id': sessionId,  // Use a session ID to maintain context
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String botResponse = data['response'];

      // Add bot response to chat
      setState(() {
        _messages.add({"role": "bot", "content": botResponse});
      });
    } else {
      setState(() {
        _messages.add({"role": "bot", "content": "Error: Failed to connect to the server."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatBot"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
