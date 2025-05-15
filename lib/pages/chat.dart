import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'dart:async';

class Chat extends StatefulWidget {
  final int receiverId;
  final String receiverName;

  const Chat({super.key, required this.receiverId, required this.receiverName});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Timer? _pollingTimer;
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isLoading) {
        _fetchMessages();
      }
    });
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  int? _senderId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSenderId();
  }

  Future<void> _loadSenderId() async {
    print('ChatScreen _loadSenderId called');
    final id = await _storage.read(key: 'user_id');
    if (id != null) {
      final parsedId = int.tryParse(id);
      if (parsedId != null) {
        setState(() {
          _senderId = parsedId;
        });
        await _fetchMessages();
        _startPolling();
        return;
      }
    }
    setState(() {
      _isLoading = false;
    });
    print('Error loading sender ID');
  }

  Future<void> _fetchMessages() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      print('Auth token not found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/${widget.receiverId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body) as List;

        setState(() {
          _messages =
              data.map<Map<String, String>>((msg) {
                final int senderIdFromMessage = msg['sender_id'];
                final bool isCurrentUser =
                    _senderId != null && senderIdFromMessage == _senderId;
                return {
                  'sender': isCurrentUser ? 'User' : 'Other',
                  'text': msg['message'] ?? '',
                  'timestamp':
                      (msg['created_at'] as String?)?.substring(11, 16) ?? '',
                };
              }).toList();

          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print(
          'Failed to fetch messages: ${response.statusCode}, body: ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching messages: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading messages: $e')));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ChatScreen didChangeDependencies called');
    if (_senderId == null && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      _loadSenderId();
    } else if (_senderId != null && _messages.isEmpty && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      _fetchMessages();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final token = await _storage.read(key: 'auth_token');
    if (token == null) return;

    final url = '$baseUrl/chat/send';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'receiver_id': widget.receiverId, 'message': text}),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        await _fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message: ${response.statusCode}, body: ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Show loading indicator
                    : _messages.isEmpty
                    ? const Center(
                      child: Text(
                        "No messages yet.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.indigo[900],
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['sender'] == 'User';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo[300] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              message['timestamp'] ?? '',
              style: TextStyle(
                fontSize: 11,
                color: isUser ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
