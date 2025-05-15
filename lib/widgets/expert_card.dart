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
          // Center(
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const Chat()),
          //       );
          //     },
          //     child: Text(
          //       'Chat',
          //       style: TextStyle(
          //         color: primaryOrange,
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
