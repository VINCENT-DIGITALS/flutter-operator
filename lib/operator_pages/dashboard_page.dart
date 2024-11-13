import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/appbar_navigation.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/line_chart.dart';
import '../widgets/pie_chart.dart';
import '../widgets/recent_reports.dart';
import '../widgets/recent_users.dart';
import '../widgets/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  int _secondsLeft = 7200; // 2 hours in seconds
  String _timeLeft = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    // Update the countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          _timeLeft = _formatDuration(_secondsLeft);
        });
      } else {
        setState(() {
          _timeLeft = 'Fetching weather data now...';
        });
        _secondsLeft = 7200; // Reset to 2 hours after fetch
        _fetchWeatherData();
      }
    });
  }

  // Format seconds to HH:MM:SS
  String _formatDuration(int seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = ((seconds % 3600) / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Simulate fetching and saving weather data
  void _fetchWeatherData() async {
    // Add your logic here for fetching weather data and saving it to the database
    print("Fetching weather data and saving to database...");
    // Once data is fetched and saved, reset the countdown timer
    setState(() {
      _timeLeft = 'Weather Data fetched and saved';
    });
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
                  // Countdown Timer display
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Time left until next weather fetch: $_timeLeft',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
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
                      Map<String, int> incidentTypeCounts = {};
                      for (var doc in snapshot.data!.docs) {
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
                    Map<String, int> incidentTypeCounts = {};
                    for (var doc in snapshot.data!.docs) {
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
