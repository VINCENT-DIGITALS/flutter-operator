import 'package:flutter/material.dart';

Widget buildUserItem(String description, String time) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        const Icon(Icons.circle, color: Colors.green, size: 8),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        Text(
          time,
          style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
