import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Widget buildPieChart(BuildContext context, Map<String, int>? incidentTypeCounts) {
  // Using ValueNotifier to track the touched section
  ValueNotifier<int?> touchedIndexNotifier = ValueNotifier<int?>(null);

  // Check if the data is null or empty and show a message instead of a loader
  if (incidentTypeCounts == null || incidentTypeCounts.isEmpty) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blueGrey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Not enough Logbook data to display the chart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add more data entries to view the trends over time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  return ValueListenableBuilder<int?>(
    valueListenable: touchedIndexNotifier,
    builder: (context, touchedIndex, _) {
      List<PieChartSectionData> sections = incidentTypeCounts.entries.map((entry) {
        final index = incidentTypeCounts.keys.toList().indexOf(entry.key);
        final isTouched = index == touchedIndex;
        final sectionColor = Colors.primaries[index % Colors.primaries.length];

        return PieChartSectionData(
          value: entry.value.toDouble(),
          color: sectionColor,
          title: isTouched ? '${entry.key}: ${entry.value}' : '',
          radius: isTouched ? 60 : 50,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
            background: Paint()
              ..color = sectionColor.computeLuminance() > 0.5
                  ? Colors.black.withOpacity(0.7)
                  : Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
          ),
        );
      }).toList();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Incident Distribution',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 20,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (event.isInterestedForInteractions &&
                          pieTouchResponse != null &&
                          pieTouchResponse.touchedSection != null) {
                        touchedIndexNotifier.value =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      } else {
                        touchedIndexNotifier.value = -1;
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 8,
                      backgroundColor: Colors.white,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.35,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Legend',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: incidentTypeCounts.entries.map((entry) {
                                    final index = incidentTypeCounts.keys.toList().indexOf(entry.key);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            color: Colors.primaries[index % Colors.primaries.length],
                                          ),
                                          const SizedBox(width: 8),
                                          Text('${entry.key}: ${entry.value}'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close', style: TextStyle(color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.black.withOpacity(0.8),
                elevation: 4,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Legends',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
