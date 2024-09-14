import 'package:administrator/operator_pages/announcement_page.dart';
import 'package:flutter/material.dart';
import 'package:administrator/operator_pages/post_announcement_page.dart';

import 'package:administrator/login_page/login_page.dart';
import 'package:administrator/operator_pages/citizenAccounts_page.dart';
import 'package:administrator/operator_pages/operator_dashboard_page.dart';
import 'package:administrator/operator_pages/responderAccount_page.dart';
import 'package:administrator/operator_pages/weather_Page.dart';
import 'package:administrator/services/database_service.dart';

class ResponderCustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String currentRoute;

  const ResponderCustomDrawer(
      {super.key, required this.scaffoldKey, required this.currentRoute});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<ResponderCustomDrawer> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isCitizenAccountExpanded = false;
  Map<String, dynamic>? userData;
  String? errorMessage;
  bool _isMediaExpanded = false;

  void signUserOut() async {
    await _authService.signOut(context);
  
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await _dbService.fetchCurrentUserData();
      setState(() {
        userData = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 34, 45, 67), // Custom background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 45, 55, 79),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Text(
                      'R',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 34, 45, 67),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Responder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
           
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', '/home', HomePage(),
                widget.currentRoute),
            _buildDrawerItem(Icons.wb_sunny, 'Weather', '/weather',
                WeatherPage(), widget.currentRoute),
            _buildMediaDropdown(),
            const Divider(color: Colors.white),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Sign Out', style: TextStyle(color: Colors.white)),
              onTap: signUserOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaDropdown() {
    return ExpansionTile(
      leading: Icon(Icons.post_add,
          color: _isMediaExpanded ? Colors.white : Colors.white),
      title: Text(
        'Media',
        style: TextStyle(color: _isMediaExpanded ? Colors.white : Colors.white),
      ),
      children: <Widget>[
        _buildDrawerItem(Icons.announcement, 'Announcements', '/announcements',
            AnnouncementManagement(), widget.currentRoute),
        _buildDrawerItem(Icons.post_add, 'Posts', '/Posts',
            PostAnnouncementManagement(), widget.currentRoute),
      ],
      initiallyExpanded: widget.currentRoute == '/announcements' ||
          widget.currentRoute == '/Posts',
      onExpansionChanged: (bool expanded) {
        setState(() => _isMediaExpanded = expanded);
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route,
      Widget destinationPage, String currentRoute) {
    bool isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.blue : Colors.white),
      ),
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => destinationPage,
              settings: RouteSettings(name: route),
            ),
          );
        }
      },
      tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
    );
  }
}
