// dashboard_buttons.dart
import 'package:flutter/material.dart';

class DashboardButtons extends StatelessWidget {
  const DashboardButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('REPORT', Colors.red),
            _buildButton('SOS', Colors.green),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton('Evacuation Map', Colors.grey),
            _buildButton('Hotline Directories', Colors.black54),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String title, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(title),
    );
  }
}
