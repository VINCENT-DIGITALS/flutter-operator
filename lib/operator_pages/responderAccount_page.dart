import 'package:administrator/components/loading.dart';
import 'package:administrator/operator_pages/responderDataTable.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import CustomDrawer
import 'package:cloud_functions/cloud_functions.dart';

class ResponderAccountManagementPage extends StatefulWidget {
  const ResponderAccountManagementPage({super.key});

  @override
  _ResponderAccountManagementPageState createState() =>
      _ResponderAccountManagementPageState();
}

class _ResponderAccountManagementPageState
    extends State<ResponderAccountManagementPage> {
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
        _dbService.fetchResponderData(); // Fetch user data from DatabaseService
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
            title: 'Responder Managements',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(
                  scaffoldKey: _scaffoldKey,
                  currentRoute: '/responder_account'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(
                      scaffoldKey: _scaffoldKey,
                      currentRoute: '/responder_account'),
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
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  border: InputBorder.none,
                                  suffixIcon:
                                      Icon(Icons.search, color: Colors.green),
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
                            // width: 800,
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;
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
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Responder Accounts'),
              Tab(text: 'Deactivated Accounts'),
              Tab(text: 'Create User'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildResponderAccountsTable(filteredData),
                _buildResponderAccountsTable(deactivatedData),
                _buildCreateUserForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponderAccountsTable(List<Map<String, dynamic>> filteredData) {
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
            columns: columns,
            source: UserDataTableSource(filteredData, columnKeys, context),
            rowsPerPage: 8,
            showCheckboxColumn: false,
            columnSpacing: 20,
            // dataRowHeight: 70,
          );
        },
      ),
    );
  }

  Widget _buildCreateUserForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              labelText: 'Password',
              icon: Icons.lock,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _displayNameController,
              labelText: 'Display Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          // Check if email already exists in Firestore
                          bool emailExists = await _dbService
                              .checkIfEmailExists(_emailController.text);
                          if (emailExists) {
                            Fluttertoast.showToast(
                              msg:
                                  "Email already been used!",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                            return;
                          }

                          // Create the responder account using Cloud Function
                          final HttpsCallable callable = FirebaseFunctions
                              .instance
                              .httpsCallable('createResponderAccount');
                          await callable.call({
                            'email': _emailController.text,
                            'password': _passwordController.text,
                            'displayName': _displayNameController.text,
                            'phoneNumber': _phoneNumberController.text,
                          });

                          Fluttertoast.showToast(
                            msg:
                                "Responder created successfully. Ask the user to verify their email.",
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 8,
                          );
                          _formKey.currentState!.reset();
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg:
                                "Failed to create responder: Please Try Again ${e}",
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 5,
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Create Responder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
