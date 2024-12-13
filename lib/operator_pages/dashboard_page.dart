import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar_navigation.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/line_chart.dart';
import '../widgets/pie_chart.dart';
import '../widgets/recent_reports.dart';
import '../widgets/recent_users.dart';
import '../widgets/stats_card.dart';
import 'mapPage/weatherService.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final WeatherService _weatherService;
  bool _isDialogOpen = false;
  final ValueNotifier<bool> _isExpanded =
      ValueNotifier<bool>(false); // State for text expansion

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService(); // Get singleton instance
    _weatherService
        .startFetchingWeather(); // Start (or resume) the weather service countdown
    // Set up callbacks
  }

  @override
  void dispose() {
    // Clear the callbacks to prevent memory leaks

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        isLargeScreen: isLargeScreen,
        scaffoldKey: _scaffoldKey,
        title: 'Dashboard',
      ),
      drawer: isLargeScreen
          ? null
          : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/home'),
      body: Row(
        children: [
          if (isLargeScreen)
            Container(
              width: 250, // Fixed width for the drawer on large screens
              child: CustomDrawer(
                scaffoldKey: _scaffoldKey,
                currentRoute: '/home',
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: _weatherService.countdownNotifier,
                    builder: (context, timeLeft, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.timer, color: Colors.blue),
                            onPressed: () {}, // Add functionality if needed
                          ),
                          Expanded(
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _isExpanded,
                              builder: (context, isExpanded, child) {
                                return GestureDetector(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth > 400) {
                                        // Use Row for wider screens
                                        return Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Time until next weather data fetch: $timeLeft',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                        );
                                      } else {
                                        // Use Column for smaller screens
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Time until next weather data fetch: $timeLeft',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 2),
                          _buildStatsRow(),
                          const SizedBox(height: 16),
                          _buildChartsRow(),
                          const SizedBox(height: 16),
                          buildRecentActivity(),
                          const SizedBox(height: 16),
                          buildRecentUsers(),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('citizens').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        int activatedCitizens = snapshot.data!.docs
            .where((doc) => doc['status'] != 'Deactivated')
            .length;
        int deactivatedCitizens = snapshot.data!.docs
            .where((doc) => doc['status'] == 'Deactivated')
            .length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildStatCard(
                'Active Citizens', activatedCitizens.toString(), Colors.green),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('responders')
                  .snapshots(),
              builder:
                  (context, AsyncSnapshot<QuerySnapshot> responderSnapshot) {
                if (!responderSnapshot.hasData) {
                  return buildStatCard(
                      'Responders', 'Loading...', Colors.orange);
                }
                int respondersCount = responderSnapshot.data!.size;
                return buildStatCard(
                    'Responders', respondersCount.toString(), Colors.orange);
              },
            ),
            buildStatCard('Deactivated Citizens',
                deactivatedCitizens.toString(), Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow() {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    const double chartHeight = 300;

    return isLargeScreen
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: SizedBox(
                  height: chartHeight,
                  child: buildLineChart(context),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 2,
                child: SizedBox(
                  height: chartHeight,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('logBook')
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
                      Map<String, int> incidentTypeCounts = {};
                      for (var doc in nonArchivedDocs) {
                        String incidentType = doc['incidentType'] ?? 'Unknown';
                        incidentTypeCounts[incidentType] =
                            (incidentTypeCounts[incidentType] ?? 0) + 1;
                      }
                      return buildPieChart(context, incidentTypeCounts);
                    },
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                height: chartHeight,
                child: buildLineChart(context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: chartHeight,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('logBook')
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

                    Map<String, int> incidentTypeCounts = {};
                    for (var doc in nonArchivedDocs) {
                      String incidentType = doc['incidentType'] ?? 'Unknown';
                      incidentTypeCounts[incidentType] =
                          (incidentTypeCounts[incidentType] ?? 0) + 1;
                    }
                    return buildPieChart(context, incidentTypeCounts);
                  },
                ),
              ),
            ],
          );
  }
}
