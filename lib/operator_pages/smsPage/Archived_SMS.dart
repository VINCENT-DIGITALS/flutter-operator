import 'package:administrator/components/loading.dart';
import 'package:administrator/operator_pages/responderDataTable.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ArchivedSMS_download_options_dialog.dart';
import 'Archived_Sms_table.dart';
import 'smsPage.dart';
import 'sms_Archived_helper.dart';
import 'SMS_download_options_dialog.dart';
import 'Sms_table.dart';
import 'select_userGroup.dart';
import 'send_sms_dialog.dart';
import 'sms_service.dart';

class ArchivedSmsManagementPage extends StatefulWidget {
  const ArchivedSmsManagementPage({super.key});

  @override
  _ArchivedSmsManagementPageState createState() =>
      _ArchivedSmsManagementPageState();
}

class _ArchivedSmsManagementPageState extends State<ArchivedSmsManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = "";
  late Stream<List<Map<String, dynamic>>> userStream;
  String role = 'Unknown';

  @override
  void initState() {
    super.initState();
    userStream = _dbService.fetchSMSData();
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => ArchivedSMSDownloadDialog(),
    );
  }

  void _sendSMSDialog() {
    showDialog(
      context: context,
      builder: (context) => UserGroupSelectionDialog(),
    );
  } // Trigger the reauthentication dialog

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 800;

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            isLargeScreen: isLargeScreen,
            scaffoldKey: _scaffoldKey,
            title: 'Archived SMS Managements',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/sms'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(
                      scaffoldKey: _scaffoldKey, currentRoute: '/sms'),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 600,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Check if the width is small for responsive layout
                                  bool isSmallScreen =
                                      constraints.maxWidth < 400;

                                  return isSmallScreen
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0,
                                              ),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  labelText: 'Search',
                                                  labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  border: InputBorder.none,
                                                  suffixIcon: Icon(Icons.search,
                                                      color: Colors.green),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _searchQuery = value;
                                                  });
                                                },
                                              ),
                                            ),
                                            const Divider(
                                                thickness:
                                                    1.0), // Divider added here
                                            const SizedBox(height: 8.0),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('sms')
                                                  .where('archived',
                                                      isEqualTo: true)
                                                  .orderBy('timestamp',
                                                      descending: true)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData ||
                                                    snapshot
                                                        .data!.docs.isEmpty) {
                                                  return SizedBox
                                                      .shrink(); // No documents available
                                                }
                                                return Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  spacing: 8.0,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.download,
                                                          color: Colors.blue),
                                                      tooltip: 'Download SMS',
                                                      onPressed:
                                                          _showDownloadDialog,
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red),
                                                      tooltip: 'Unarchive SMS',
                                                      onPressed: () {
                                                        SMSUnArchivingHelper
                                                            .initialConfirmation(
                                                          context,
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.archive,
                                                          color: Colors.orange),
                                                      tooltip: 'View SMS',
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SmsManagementPage(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8.0),
                                            const Divider(
                                                thickness:
                                                    1.0), // Divider added here
                                            // TextButton.icon(
                                            //   style: TextButton.styleFrom(
                                            //     foregroundColor: Colors.blue,
                                            //   ),
                                            //   onPressed: _sendSMSDialog,
                                            //   icon: Icon(Icons.sms),
                                            //   label: Text('Send Message'),
                                            // ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 8.0,
                                                ),
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    labelText: 'Search',
                                                    labelStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    border: InputBorder.none,
                                                    suffixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors.green),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _searchQuery = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('sms')
                                                  .orderBy('timestamp',
                                                      descending: true)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData ||
                                                    snapshot
                                                        .data!.docs.isEmpty) {
                                                  return SizedBox
                                                      .shrink(); // No documents available
                                                }
                                                return Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.download,
                                                          color: Colors.blue),
                                                      tooltip: 'Download SMS',
                                                      onPressed:
                                                          _showDownloadDialog,
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red),
                                                      tooltip: 'Unarchive SMS',
                                                      onPressed: () {
                                                        SMSUnArchivingHelper
                                                            .initialConfirmation(
                                                          context,
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.archive,
                                                          color: Colors.orange),
                                                      tooltip: 'View SMS',
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SmsManagementPage(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            // TextButton.icon(
                                            //   style: TextButton.styleFrom(
                                            //     foregroundColor: Colors.blue,
                                            //   ),
                                            //   onPressed: _sendSMSDialog,
                                            //   icon: Icon(Icons.sms),
                                            //   label: Text('Send Message'),
                                            // ),
                                          ],
                                        );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
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
                                          child:
                                              Text('No SMS record available!'));
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
      DataColumn(label: Text('Submitted At')),
      DataColumn(label: Text('Message')),
      DataColumn(label: Text('# Failed')),
      DataColumn(label: Text('# Sent')),
      DataColumn(label: Text('Status')),
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
    });
  }).toList();

  return DefaultTabController(
    length: 1,
    child: Column(
      children: [
        Container(
          // color: Colors.grey[100], // Background for the entire TabBar section
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the tab
            children: [
              TabBar(
                isScrollable: true, // Allow minimal width for the tab
                labelColor: Colors.white, // Active tab text color
                unselectedLabelColor: Colors.black54, // Inactive tab text color
                indicatorSize: TabBarIndicatorSize.label, // Shrink the box to fit the label
                indicator: BoxDecoration(
                  color: Colors.deepPurple, // Background color for active tab
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3), // Shadow effect for depth
                    ),
                  ],
                ),
                indicatorPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Minimal padding
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Emphasize active tab text
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('SMS Records'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildIncentLogBooksTable(filteredData),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildIncentLogBooksTable(List<Map<String, dynamic>> filteredData) {
    // Filter and sort data based on conditions
    List<Map<String, dynamic>> smsData;

    smsData = filteredData.where((item) {
      final isArchived = (item['archived']); // Explicit check for true
      return isArchived == true;
    }).toList();

// Sort each group by latest timestamp
    smsData.sort((a, b) {
      DateTime timestampA = (a['timestamp'] is Timestamp)
          ? a['timestamp'].toDate()
          : (a['timestamp'] ?? DateTime(0));

      DateTime timestampB = (b['timestamp'] is Timestamp)
          ? b['timestamp'].toDate()
          : (b['timestamp'] ?? DateTime(0));

      return timestampB.compareTo(timestampA); // Sort in descending order
    });

// Combine both lists, prioritizing non-completed reports
    List<Map<String, dynamic>> sortedData = smsData;

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _getColumns(constraints.maxWidth);
          final columnKeys = [
            "timestamp",
            "message",
            "numFailed",
            "numSuccess",
            "status",
            "actions",
          ];

          return PaginatedDataTable(
            columns: columns,
            source: ArchivedSmsDataTableSource(sortedData, columnKeys, context),
            rowsPerPage: 9,
            showCheckboxColumn: false,
            columnSpacing: 20,
          );
        },
      ),
    );
  }
}
