import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:administrator/widgets/sms_announce.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences? _prefs;
  String? role;

  @override
  void initState() {
    role = GetStorage().read('role');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

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
              width: 250,
              child: CustomDrawer(
                  scaffoldKey: _scaffoldKey, currentRoute: '/home'),
            ),
          Expanded(
            child: _buildDashboard(),
          ),
        ],
      ),
    );
  }

Widget _buildDashboard() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with buttons
        _buildHeader(),
        SizedBox(height: 16.0),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine the number of columns based on the screen size
              int crossAxisCount = constraints.maxWidth > 1200
                  ? 3
                  : (constraints.maxWidth > 800 ? 2 : 1);
              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 1200, // Restrict the maximum width of the grid
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      // Restrict the maximum height of each grid item
                      childAspectRatio: 3 / 2, // Adjust the ratio as needed
                    ),
                    itemCount: 4, // Number of grid items
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Weather integrated in the first box
                        return Card(
                          color: Colors.lightBlue[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: WeatherWidget(),
                          ),
                        );
                      } else {
                        // Other dashboard cards
                        List<Map<String, dynamic>> cardsData = [
                          {'title': 'Summary of Citizens', 'icon': Icons.person, 'color': Colors.orange},
                          {'title': 'Summary for Responders', 'icon': Icons.security, 'color': Colors.blue},
                          {'title': 'Future Usage 1', 'icon': Icons.update, 'color': Colors.green},
                        ];
                        return _buildDashboardCard(
                          cardsData[index - 1]['title'],
                          cardsData[index - 1]['icon'],
                          cardsData[index - 1]['color'],
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.create, size: 18),
          label: Text('Create Report'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF36CFC9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            showSmsAnnouncementDialog(context);
          },
          icon: Icon(Icons.create, size: 18),
          label: Text('SMS Announcement'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF36CFC9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF223049),
              ),
            ),
            // Additional content can be added here if needed
          ],
        ),
      ),
    );
  }
}
