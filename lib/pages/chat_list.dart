import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
        backgroundColor: Colors.indigo[900],
      ),
      body: const Center(child: Text('List of chats will appear here')),
    );
  }
}
