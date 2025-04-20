import 'package:flutter/material.dart';
import 'package:repair_app/pages/chat.dart';

const Color primaryOrange = Color(0xFFFF9800);

class ExpertCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String job;

  const ExpertCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundImage: AssetImage(imagePath), radius: 30),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            job,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Chat()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Chat'),
            ),
          ),
        ],
      ),
    );
  }
}
