import 'package:flutter/material.dart';

import 'list_responder.dart';

class LogBookVictimDetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const LogBookVictimDetailSection({Key? key, required this.data}) : super(key: key);

  // Extract victim details from the 'victims' array
  List<Map<String, dynamic>> _getVictimDetails() {
    final victims = data["victims"] as List<dynamic>? ?? [];
    return victims
        .map((victim) => {
              "name": victim["name"]?.toString() ?? 'Unknown',
              "address": victim["address"]?.toString() ?? 'N/A',
              "age": victim["age"]?.toString() ?? 'N/A',
              "injury": victim["injury"]?.toString() ?? 'N/A',
              "sex": victim["sex"]?.toString() ?? 'N/A',
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final victimDetails = _getVictimDetails(); // List of victim details

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
          Text("Victims", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          // Display details for each victim
          ...victimDetails.map((victim) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LogBookResponderListItem(label: "Name", value: victim["name"]),
                LogBookResponderListItem(label: "Address", value: victim["address"]),
                LogBookResponderListItem(label: "Age", value: victim["age"]),
                LogBookResponderListItem(label: "Injury", value: victim["injury"]),
                LogBookResponderListItem(label: "Life Status", value: victim["lifeStatus"]),
                LogBookResponderListItem(label: "Sex", value: victim["sex"]),
                Divider(color: Colors.grey),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
