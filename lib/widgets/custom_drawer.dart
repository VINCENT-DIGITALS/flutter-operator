import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:administrator/login_page/login_page.dart';
import 'package:administrator/operator_pages/my_account.dart';
import 'package:administrator/operator_pages/announcement_page.dart';
import 'package:administrator/operator_pages/post_announcement_page.dart';
import 'package:administrator/operator_pages/citizenAccounts_page.dart';
import 'package:administrator/operator_pages/operator_dashboard_page.dart';
import 'package:administrator/operator_pages/responderAccount_page.dart';
import 'package:administrator/operator_pages/weather_Page.dart';
import 'package:administrator/services/database_service.dart';

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
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isAccountsExpanded = false;
  bool _isMediaExpanded = false;
  SharedPreferences? _prefs;
  Map<String, String> _userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _fetchAndDisplayUserData();
  }

  Future<void> _fetchAndDisplayUserData() async {
    setState(() {
      _userData = {
        'uid': _prefs?.getString('uid') ?? '',
        'email': _prefs?.getString('email') ?? '',
        'displayName': _prefs?.getString('displayName') ?? 'Admin',
        'photoURL': _prefs?.getString('photoURL') ?? 'A',
        'phoneNum': _prefs?.getString('phoneNum') ?? '',
        'createdAt': _prefs?.getString('createdAt') ?? '',
        'address': _prefs?.getString('address') ?? '',
        'status': _prefs?.getString('status') ?? '',
        'type': _prefs?.getString('type') ?? 'Admin',
      };
      isLoading = false;
    });
  }

  void _showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                signUserOut(); // Call sign out method
              },
              child: Text('Sign Out'),
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

  void _showSmsAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.people),
                title: Text('SMS Announcement to All Users'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _sendSmsAnnouncementToAll();
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('SMS Announcement to Specific User'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _sendSmsAnnouncementToSpecificUser();
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('In-App Message Announcement'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _sendInAppMessageAnnouncement();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendSmsAnnouncementToAll() {
    // Implement your logic for sending SMS to all users
    print('Sending SMS to all users...');
  }

  void _sendSmsAnnouncementToSpecificUser() {
    // Implement your logic for sending SMS to a specific user
    print('Sending SMS to a specific user...');
  }

  void _sendInAppMessageAnnouncement() {
    // Implement your logic for sending in-app message announcement
    print('Creating in-app message announcement...');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Drawer(
        child: Center(child: CircularProgressIndicator()), // Show a loading indicator
      );
    }

    bool isLoggedIn = _userData['uid']?.isNotEmpty == true;
    String firstLetter = _userData['displayName']?.isNotEmpty == true ? _userData['displayName']!.substring(0, 1) : '';
    String role = _userData['type'] ?? 'Admin';

    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 34, 45, 67), // Custom background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 45, 55, 79),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Text(
                      firstLetter.isEmpty ? '?' : firstLetter,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 34, 45, 67),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userData['displayName'] ?? ' ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', '/home', HomePage(), widget.currentRoute),
            _buildDrawerItem(Icons.wb_sunny, 'Weather', '/weather', WeatherPage(), widget.currentRoute),
            _buildMediaDropdown(role), // Pass the role to the media dropdown
            _buildAccountsDropdown(role), // Pass the role to the accounts dropdown
            const Divider(color: Colors.white),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
              onTap: _showSignOutConfirmationDialog, // Show confirmation dialog before signing out
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaDropdown(String role) {
    return ExpansionTile(
      leading: Icon(Icons.post_add, color: _isMediaExpanded ? Colors.white : Colors.white),
      title: Text(
        'Media',
        style: TextStyle(color: _isMediaExpanded ? Colors.white : Colors.white),
      ),
      children: <Widget>[
        _buildDrawerItem(Icons.announcement, 'Announcements', '/announcements', AnnouncementManagement(), widget.currentRoute),
        _buildDrawerItem(Icons.post_add, 'Posts', '/Posts', PostAnnouncementManagement(), widget.currentRoute),
        if (role == 'Operator') // Check if the user role is Operator
          ListTile(
            leading: Icon(Icons.sms, color: Colors.white),
            title: Text('SMS Announcement', style: TextStyle(color: Colors.white)),
            onTap: _showSmsAnnouncementDialog,
          ),
      ],
      initiallyExpanded: widget.currentRoute == '/announcements' || widget.currentRoute == '/Posts',
      onExpansionChanged: (bool expanded) {
        setState(() => _isMediaExpanded = expanded);
      },
    );
  }

  Widget _buildAccountsDropdown(String role) {
    return ExpansionTile(
      leading: Icon(Icons.person, color: _isAccountsExpanded ? Colors.white : Colors.white),
      title: Text(
        'Accounts',
        style: TextStyle(color: _isAccountsExpanded ? Colors.white : Colors.white),
      ),
      children: <Widget>[
        _buildDrawerItem(Icons.account_circle, 'My Account', '/My Account', MyAccountPage(), widget.currentRoute),
        if (role == 'Operator') ...[
          _buildDrawerItem(Icons.people, 'Citizen Accounts', '/citizen_accounts', UserAccountManagementPage(), widget.currentRoute),
          _buildDrawerItem(Icons.settings, 'Responder Accounts', '/responder_accounts', ResponderAccountManagementPage(), widget.currentRoute),
        ],
      ],
      initiallyExpanded: widget.currentRoute == '/citizen_accounts' || widget.currentRoute == '/responder_accounts',
      onExpansionChanged: (bool expanded) {
        setState(() => _isAccountsExpanded = expanded);
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route, Widget destinationPage, String currentRoute) {
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
