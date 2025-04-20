import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  // Function to add a new message to the Chat
  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      // prevent empty messages
      setState(() {
        _messages.add({
          'sender': 'User', // or 'Specialist'
          'text': text,
          'timestamp': DateTime.now().toString(),
        });
      });
      _messageController.clear();
      // back end
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ali Ahmad"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo[900], 
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border:
                            InputBorder
                                .none, // Remove border to match the style
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ), // Hint text color
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white), // Text color
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ), // Button color
                    onPressed: () {
                      _sendMessage(_messageController.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a single message bubble
  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['sender'] == 'User';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isUser
                  ? Colors.blue[200]
                  : Colors.grey[300], // Default for Specialist
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message['text'] ?? '', style: const TextStyle(fontSize: 16)),
            Text(
              message['timestamp'] != null
                  ? message['timestamp']!.substring(11, 16)
                  : '',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
