import 'package:flutter/material.dart';

class UserSpecialistToggle extends StatefulWidget {
  final ValueChanged<String> onToggle;
  final String initialValue;

  const UserSpecialistToggle({
    super.key,
    required this.onToggle,
    this.initialValue = 'User',
  });

  @override
  State<UserSpecialistToggle> createState() => _UserSpecialistToggleState();
}

class _UserSpecialistToggleState extends State<UserSpecialistToggle> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  void _toggle(String value) {
    setState(() => selected = value);
    widget.onToggle(value);  // Notify parent of the new selected value
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF9800);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildOption('User', primaryOrange),
          _buildOption('Specialist', primaryOrange),
        ],
      ),
    );
  }

  Widget _buildOption(String value, Color activeColor) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _toggle(value),  // Toggle the value
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
