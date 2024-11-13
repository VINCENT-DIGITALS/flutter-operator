// incident_reports_chart.dart
import 'package:flutter/material.dart';

class IncidentReportsChart extends StatelessWidget {
  const IncidentReportsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically adjust chart height and padding based on available space
        double chartHeight = constraints.maxWidth < 600 ? 100 : 150;
        double fontSize = constraints.maxWidth < 600 ? 14 : 16;
        double horizontalPadding = constraints.maxWidth < 600 ? 8 : 16;
        double verticalPadding = constraints.maxWidth < 600 ? 4 : 8;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Container(
            height: chartHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Chart", // Placeholder for the actual chart widget
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
