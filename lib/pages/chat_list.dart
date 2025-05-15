import 'dart:convert';
import '../../constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/widgets/custom_appbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chat.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  static const Color primaryOrange = Color(0xFFFFA726);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    try {
      final uri = Uri.parse('$baseUrl/chat-list');
      final token = await storage.read(key: 'auth_token');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _users =
              data
                  .map<Map<String, dynamic>>(
                    (item) => {
                      'name': item['first_name'] ?? '',
                      'lastMessage': item['last_message'] ?? '',
                      'time': item['timestamp'] ?? '',
                      'profileImage': item['profile_image'] ?? '',
                      'userId': item['user_id'] ?? 0,
                    },
                  )
                  .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load chats: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: "Chat"),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver:
                _users.isEmpty
                    ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "No chats yet",
                          style: const TextStyle(
                            fontSize: 18,
                            color: ChatList.primaryOrange,
                          ),
                        ),
                      ),
                    )
                    : SliverList(
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
                              backgroundImage:
                                  user['profileImage'].isNotEmpty
                                      ? NetworkImage(user['profileImage'])
                                      : null,
                              child:
                                  user['profileImage'].isEmpty
                                      ? Text(user['name'][0])
                                      : null,
                            ),
                            title: Text(
                              user['name'],
                              style: const TextStyle(
                                color: ChatList.primaryOrange,
                              ),
                            ),
                            subtitle: Text(user['lastMessage']),
                            trailing: Text(user['time']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => Chat(
                                        receiverId: user['userId'],
                                        receiverName: user['name'],
                                      ),
                                ),
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
