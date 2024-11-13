
import 'package:flutter/material.dart';

import 'vehicles_section.dart';

class LogBookVehicleDetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const LogBookVehicleDetailSection({Key? key, required this.data}) : super(key: key);

    // Extract VEHICLES names from the 'responders' array
  List<String> _getVehicleDetails() {
    final responders = data["vehicles"] as List<dynamic>? ?? [];
    return responders
        .map((responder) => responder["vehicleType"]?.toString() ?? 'Unknown')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final responderNames = _getVehicleDetails(); // List of responder names

    return Container(
      padding: EdgeInsets.all(12),
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vehicles", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          // Display list of responder names
          ...responderNames.map((name) => LogBookVehicleListItem(label: "Vehicle Type", value: name)).toList(),
        ],
      ),
    );
  }
}
