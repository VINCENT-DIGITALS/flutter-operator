import 'package:flutter/material.dart';
import 'package:administrator/login_page/login_page.dart';
import 'package:administrator/operator_pages/announcement_page.dart';
import 'package:administrator/operator_pages/citizenAccounts_page.dart';
import 'package:administrator/operator_pages/dashboard_page.dart';
import 'package:administrator/operator_pages/responderAccount_page.dart';

import '../operator_pages/chatPage/chat_list.dart';
import '../operator_pages/incident_reports_page.dart';
import '../operator_pages/logbook_page.dart';
import '../operator_pages/mapPage/map_page.dart';
import '../operator_pages/smsPage/smsPage.dart';
import '../services/database_service.dart';

class CustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String currentRoute;

  const CustomDrawer({
    Key? key,
    required this.scaffoldKey,
    required this.currentRoute,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _authService = AuthService();

  bool isLoading = true;
  // Add state to track subcategory visibility
  bool showSubcategories = false;
  @override
  void initState() {
    super.initState();
    // Simulate loading or any other initialization if needed
    setState(() {
      isLoading = false;
    });
  }

  void _showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                signUserOut(); // Call sign out method
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void signUserOut() async {
    await _authService.signOut(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Drawer(
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Drawer(
      child: Container(
        color: const Color(0xFF202D40),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Working space',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', '/home', HomePage(),
                widget.currentRoute),
            _buildDrawerItem(
                Icons.announcement,
                'Announcements',
                '/Announcements',
                AnnouncementManagement(),
                widget.currentRoute),
            _buildDrawerItem(
                Icons.receipt,
                'Incident Reports',
                '/incident_reports',
                IncidentReportManagementPage(),
                widget.currentRoute),
            _buildDrawerItem(Icons.book, 'Log Book', '/logbook',
                LogBookManagementPage(), widget.currentRoute),
            _buildDrawerItem(Icons.sms, 'SMS', '/sms', SmsManagementPage(),
                widget.currentRoute),
            _buildDrawerItem(Icons.map, 'Weather Map', '/map', MapPageMain(),
                widget.currentRoute),
            _buildDrawerItem(
              Icons.chat,
              'Group Chats',
              '/group_chat',
              ChatListPage(),
              widget.currentRoute,
              onTap: () {
                setState(() {
                  showSubcategories = !showSubcategories;
                });
              },
              isExpandable: true,
              isExpanded: showSubcategories,
            ),
            if (showSubcategories) ...[
              _buildSubcategoryItem('Team Chat'),
            ],
            const Divider(color: Colors.white70),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Manage Accounts',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _buildDrawerItem(Icons.people, 'Responders', '/responder_account',
                ResponderAccountManagementPage(), widget.currentRoute),
            _buildDrawerItem(
                Icons.people_outline,
                'Citizens',
                '/citizen_accounts',
                UserAccountManagementPage(),
                widget.currentRoute),
            const Divider(color: Colors.white70),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Sign Out', style: TextStyle(color: Colors.white)),
              onTap: _showSignOutConfirmationDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
        onTap: () {
          // Handle subcategory action
        },
      ),
    );
  }

  void _showSubcategories() {
    setState(() {
      showSubcategories = !showSubcategories;
    });
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFF1C2535),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // Show full-screen image when tapped
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pop(), // Close dialog on tap
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10), // Optional rounded corners
                      child: Image.asset(
                        'assets/images/LOGOAPP0.png', // Your image path
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: ClipOval(
              child: Image.asset(
                'assets/images/LOGOAPP0.png', // Your image path
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Operator Panel',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    String route,
    Widget destinationPage,
    String currentRoute, {
    VoidCallback? onTap,
    bool isExpandable = false,
    bool isExpanded = false,
  }) {
    bool isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.orange : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.orange : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
    );
  }
}
