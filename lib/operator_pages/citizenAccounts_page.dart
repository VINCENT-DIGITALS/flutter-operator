import 'package:administrator/components/loading.dart';
import 'package:administrator/operator_pages/citizenDataTable.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import CustomDrawer

class UserAccountManagementPage extends StatefulWidget {
  const UserAccountManagementPage({super.key});

  @override
  _UserAccountManagementPageState createState() =>
      _UserAccountManagementPageState();
}

class _UserAccountManagementPageState extends State<UserAccountManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _dbService =
      DatabaseService(); // Instantiate DatabaseService
  String _searchQuery = "";
  late Stream<List<Map<String, dynamic>>> userStream;
  String role = 'Unknown';
  SharedPreferences? _prefs;
  Map<String, String> _userData = {};


  @override
  void initState() {
    _initializePreferences();
    super.initState();
    userStream =
        _dbService.fetchUserData(); // Fetch user data from DatabaseService
  }

  void _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _fetchAndDisplayUserData();
  }

  Future<void> _fetchAndDisplayUserData() async {
    try {
      _userData = {
        'uid': _prefs?.getString('uid') ?? '',
        'email': _prefs?.getString('email') ?? '',
        'displayName': _prefs?.getString('displayName') ?? '',
        'photoURL': _prefs?.getString('photoURL') ?? '',
        'phoneNum': _prefs?.getString('phoneNum') ?? '',
        'createdAt': _prefs?.getString('createdAt') ?? '',
        'address': _prefs?.getString('address') ?? '',
        'status': _prefs?.getString('status') ?? '',
        'role': _prefs?.getString('role') ?? '',
      };
      print('Role: ${_userData['role']}');
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if screen width is larger than 600 pixels
        bool isLargeScreen = constraints.maxWidth > 800;

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            isLargeScreen: isLargeScreen,
            scaffoldKey: _scaffoldKey,
            title: 'Citizen Managements',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(
                  scaffoldKey: _scaffoldKey, currentRoute: '/citizen_accounts'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(
                      scaffoldKey: _scaffoldKey,
                      currentRoute: '/citizen_accounts'),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 400,
                          margin: const EdgeInsets.only(
                              bottom: 8.0), // Adjusted margin
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  labelStyle: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                  border: InputBorder.none,
                                  suffixIcon: Icon(Icons.search,
                                      color: Colors.deepPurple),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            // width: 600,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:
                                    StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: userStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                          child: Text('No data found.'));
                                    } else {
                                      return UserAccountsTable(
                                        searchQuery: _searchQuery,
                                        data: snapshot.data!,
                                        filter: 'active',
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
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
      },
    );
  }
}

class UserAccountsTable extends StatefulWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> data;
  final String filter;

  UserAccountsTable({
    required this.searchQuery,
    required this.data,
    required this.filter,
  });

  @override
  _UserAccountsTableState createState() => _UserAccountsTableState();
}

class _UserAccountsTableState extends State<UserAccountsTable> {
  List<DataColumn> _getColumns(double width) {
    return [
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Email')),
      DataColumn(label: Text('Phone Number')),
      DataColumn(label: Text('Date Created')),
      DataColumn(label: Text('Actions')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = widget.data.where((user) {
      String query = widget.searchQuery.toLowerCase(); // Lowercase query

      // Check if any value in the user map contains the search query
      return user.values.any((value) {
            return value.toString().toLowerCase().contains(query);
          }) &&
          user['status'] != 'Deactivated';
    }).toList();

    List<Map<String, dynamic>> deactivatedData = widget.data.where((user) {
      String query = widget.searchQuery.toLowerCase();

      return user.values.any((value) {
            return value.toString().toLowerCase().contains(query);
          }) &&
          user['status'] != 'Activated';
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Citizen Accounts'),
              Tab(text: 'Deactivated Accounts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCitizenAccountsTable(filteredData),
                _buildCitizenAccountsTable(deactivatedData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenAccountsTable(List<Map<String, dynamic>> filteredData) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _getColumns(constraints.maxWidth);
          final columnKeys = [
            "status",
            "name",
            "email",
            "phone number",
            "createdAt",
            "actions"
          ];

          return PaginatedDataTable(
            header: Text('Citizen Accounts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            columns: columns,
            source: UserDataTableSource(filteredData, columnKeys, context),
            rowsPerPage: 8,
            showCheckboxColumn: false,
            columnSpacing: 20,
            // ignore: deprecated_member_use
            // dataRowHeight: 70,
          );
        },
      ),
    );
  }
}
