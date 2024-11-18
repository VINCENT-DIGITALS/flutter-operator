import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Widget buildLineChart(BuildContext context) {
  ValueNotifier<String> selectedRange = ValueNotifier<String>('7 days');
  // ValueNotifier<DateTime?> customStartDate = ValueNotifier<DateTime?>(null);
  ValueNotifier<DateTime?> customEndDate = ValueNotifier<DateTime?>(null);

  // Helper function to get the start date based on selected range
  DateTime? getStartDate() {
    final now = DateTime.now();
    switch (selectedRange.value) {
      case '3 days':
        return now.subtract(const Duration(days: 3));
      case '7 days':
        return now.subtract(const Duration(days: 7));
      case '1 month':
        return DateTime(now.year, now.month - 1, now.day);
      case '1 year':
        return DateTime(now.year - 1, now.month, now.day);
      case 'Everything':
        return null; // No date restriction
      // case 'Custom Range':
      //   return customStartDate.value;
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  DateTime? getEndDate() {
    return selectedRange.value == 'Custom Range'
        ? customEndDate.value
        : DateTime.now();
  }

  // Future<void> pickCustomDateRange(BuildContext context) async {
  //   DateTimeRange? pickedRange = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(1900), // Allow selection from as far back as 1900
  //     lastDate: DateTime.now(), // Limit selection to the current date
  //     initialDateRange: DateTimeRange(
  //       start: customStartDate.value ??
  //           DateTime.now().subtract(const Duration(days: 365)),
  //       end: customEndDate.value ?? DateTime.now(),
  //     ),
  //   );

  //   if (pickedRange != null) {
  //     customStartDate.value = pickedRange.start;
  //     customEndDate.value = pickedRange.end;
  //   }
  // }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Incident Trends',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Container for the dropdown with styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey[200]!),
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: selectedRange,
                builder: (context, range, _) {
                  return DropdownButton<String>(
                    value: range,
                    underline: SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.blueGrey),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        selectedRange.value = newValue;
                        // if (newValue == 'Custom Range') {
                        //   await pickCustomDateRange(context);
                        // }
                      }
                    },
                    items: <String>[
                      '3 days',
                      '7 days',
                      '1 month',
                      '1 year',
                      'Everything',
                      // 'Custom Range'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Chart StreamBuilder
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: selectedRange,
            builder: (context, range, _) {
              DateTime? startDate = getStartDate();
              DateTime? endDate = getEndDate();

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('logBook')
                    .where('timestamp', isGreaterThanOrEqualTo: startDate)
                    .where('timestamp', isLessThanOrEqualTo: endDate)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Filter out archived logBook entries
                  final nonArchivedDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['archived'] == null ||
                        data['archived'] == false;
                  });

                  Map<String, int> dateCounts = {};
                  for (var doc in nonArchivedDocs) {
                    Timestamp timestamp = doc['timestamp'];
                    DateTime date = timestamp.toDate();
                    if ((startDate == null || date.isAfter(startDate)) &&
                        (endDate == null || date.isBefore(endDate))) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(date);
                      dateCounts[formattedDate] =
                          (dateCounts[formattedDate] ?? 0) + 1;
                    }
                  }

                  if (dateCounts.length < 2) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.blueGrey.withOpacity(0.3)),
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

                  List<FlSpot> spots = [];
                  List<String> dates = dateCounts.keys.toList()..sort();

                  for (int i = 0; i < dates.length; i++) {
                    spots.add(
                        FlSpot(i.toDouble(), dateCounts[dates[i]]!.toDouble()));
                  }

                  double screenWidth = MediaQuery.of(context).size.width;
                  int maxLabels = (screenWidth ~/ 100).clamp(2, dates.length);
                  int interval = (dates.length / maxLabels).ceil();
                  double maxYValue =
                      spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
                  int yInterval = (maxYValue / 5).ceil();

                  return SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: yInterval.toDouble(),
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  interval: interval.toDouble(),
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    bool isLargeScreen = screenWidth > 600;

                                    if (index % interval == 0 &&
                                        index < dates.length) {
                                      EdgeInsets padding =
                                          (index == dates.length - 1 &&
                                                  isLargeScreen)
                                              ? const EdgeInsets.only(left: 8)
                                              : EdgeInsets.zero;

                                      // Format the date to show only the month and day
                                      String formattedDate =
                                          DateFormat('MM-dd').format(
                                        DateTime.parse(dates[index]),
                                      );

                                      return Padding(
                                        padding: padding,
                                        child: Text(
                                          formattedDate,
                                          style: const TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                top: BorderSide(color: Colors.grey, width: 1),
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1),
                                left: BorderSide(color: Colors.grey, width: 1),
                                right: BorderSide(
                                  color: Colors.transparent,
                                  width: screenWidth > 600 ? 20 : 0,
                                ),
                              ),
                            ),
                            minX: 0,
                            maxX: dates.length - 1.toDouble(),
                            minY: 0,
                            maxY: maxYValue,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Colors.blue,
                                belowBarData: BarAreaData(show: true),
                                dotData: FlDotData(show: false),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor:
                                    Colors.blueAccent.withOpacity(0.8),
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                tooltipMargin: 8,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    String date = dates[spot.x.toInt()];
                                    return LineTooltipItem(
                                      '$date\n${spot.y.toInt()} incidents',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
