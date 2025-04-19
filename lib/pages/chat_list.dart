import 'package:flutter/material.dart';
import 'chat.dart';
import '/widgets/custom_appbar.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  final Color primaryOrange = const Color(0xFFFFA726);
  final List<Map<String, String>> _users = const [
    {'name': 'Ali', 'lastMessage': 'Hey, how are you?', 'time': '10:24 AM'},
    {
      'name': 'Specialist Ahmad',
      'lastMessage': 'I fixed the pipe.',
      'time': '9:10 AM',
    },
    {
      'name': 'Fatima',
      'lastMessage': 'Thanks for the update.',
      'time': 'Yesterday',
    },
    {
      'name': 'Fatima',
      'lastMessage': 'Thanks for the update.',
      'time': 'Yesterday',
    },
    {
      'name': 'Fatima',
      'lastMessage': 'Thanks for the update.',
      'time': 'Yesterday',
    },
    {
      'name': 'Fatima',
      'lastMessage': 'Thanks for the update.',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: "Chat"),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final user = _users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[300],
                      child: Text(user['name']![0]),
                    ),
                    title: Text(
                      user['name']!,
                      style: TextStyle(color: primaryOrange),
                    ),
                    subtitle: Text(user['lastMessage']!),
                    trailing: Text(user['time']!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Chat()),
                      );
                    },
                  ),
                );
              }, childCount: _users.length),
            ),
          ),
        ],
      ),
    );
  }
}
