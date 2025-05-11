import 'package:flutter/material.dart';

class ReportStatus extends StatelessWidget {
  final String status;

  const ReportStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'Waiting':
        color = Colors.grey;
        break;
      case 'Escalated':
        color = Colors.grey;
        break;
      case 'Accepted':
        color = Colors.orange;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      case 'In Progress':
        color = Colors.blue;
        break;
      case 'Completed':
        color = Colors.green;
        break;
      default:
        color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}






