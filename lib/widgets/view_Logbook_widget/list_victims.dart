import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogBookVictimListItem extends StatelessWidget {
  final String label;
  final dynamic value;

  const LogBookVictimListItem({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayValue;

    if (value is GeoPoint) {
      displayValue = "Lat: ${value.latitude}, Lng: ${value.longitude}";
    } else if (value is Map<String, dynamic> && value.containsKey('latitude') && value.containsKey('longitude')) {
      displayValue = "Lat: ${value['latitude']}, Lng: ${value['longitude']}";
    } else {
      displayValue = value?.toString() ?? 'N/A';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }
}
