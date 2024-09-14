import 'package:administrator/services/shared_pref.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:administrator/widgets/sms_announce.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences? _prefs;
  Map<String, String> _userData = {};
  String? role;

  @override
  void initState() {
    // Retrieve role from get_storage when the drawer initializes
    role = GetStorage().read('role');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('role in dashboard: $role');
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

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
      },
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16.0),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200
                    ? 3
                    : (constraints.maxWidth > 800 ? 2 : 1);
                return Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 1200),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      children: [
                        _buildDashboardCard(
                            'Summary of Citizens', Icons.person, Colors.orange),
                        _buildDashboardCard('Summary for Responders',
                            Icons.security, Colors.blue),
                        _buildDashboardCard(
                            'Future Usage 1', Icons.update, Colors.green),
                        _buildDashboardCard(
                            'Future Usage 2', Icons.update, Colors.purple),
                      ],
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
        // Text(
        //   'Dashboard',
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.bold,
        //     color: Color(0xFF223049),
        //   ),
        // ),
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
        SizedBox(width: 16,),
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
        )
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
            // Add chart or additional content here
          ],
        ),
      ),
    );
  }
}
