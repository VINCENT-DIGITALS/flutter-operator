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

import '../Models/logbookArchive_helper.dart';
import '../widgets/download_options_dialog.dart';
import 'archivedTables/logbook/Archived_logbook_page.dart';
import 'incident_report_dataTable.dart';
import 'logbook_dataTable.dart';

class LogBookManagementPage extends StatefulWidget {
  const LogBookManagementPage({super.key});

  @override
  _LogBookManagementPageState createState() => _LogBookManagementPageState();
}

class _LogBookManagementPageState extends State<LogBookManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = "";
  late Stream<List<Map<String, dynamic>>> userStream;
  String role = 'Unknown';

  @override
  void initState() {
    super.initState();
    userStream = _dbService.fetchIncidentLogBookData();
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => DownloadDialog(),
    );
  }

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
            title: 'LogBook Managements',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(
                  scaffoldKey: _scaffoldKey, currentRoute: '/logbook'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(
                      scaffoldKey: _scaffoldKey, currentRoute: '/logbook'),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 400,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
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
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('logBook')
                                      .orderBy('timestamp', descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      // Return an empty container if there are no documents
                                      return SizedBox.shrink();
                                    }

                                    // If documents are present, display the Row with the buttons
                                    return Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.download,
                                              color: Colors.blue),
                                              tooltip: 'Download Log Book',
                                          onPressed: _showDownloadDialog,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_forever,
                                              color: Colors.red),
                                              tooltip: 'Archive Log Book',
                                          onPressed: () {
                                            LogBookArchivingHelper
                                                .initialConfirmation(context);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.archive,
                                              color: Colors.orange),
                                          tooltip: 'View Archived Log Book',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ArchivedLogBookManagementPage(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
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
                                          child: Text(
                                              'No LogBook record available!'));
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
      DataColumn(label: Text('Legitimacy')),
      DataColumn(label: Text('Accepted By')),
      DataColumn(label: Text('Incident Type')),
      DataColumn(label: Text('# Injured')),
      DataColumn(label: Text('Severity')),
      DataColumn(label: Text('Submitted At')),
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
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLogBooksTable(filteredData, 'Pending'),
                _buildLogBooksTable(filteredData, 'In Progress'),
                _buildLogBooksTable(filteredData, 'Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogBooksTable(List<Map<String, dynamic>> data, String tabType) {
    // Filter data based on tabType and archived field
    List<Map<String, dynamic>> filteredData;
    if (tabType == 'Pending') {
      filteredData = data.where((item) {
        final status = item['status']?.toString() ?? '';
        final isArchived =
            (item['archived'] == true); // Explicit check for true
        return !isArchived &&
            (status.isEmpty ||
                (status != 'Completed' && status != 'In Progress'));
      }).toList();
    } else if (tabType == 'In Progress') {
      filteredData = data.where((item) {
        final isArchived =
            (item['archived'] == true); // Explicit check for true
        return !isArchived && item['status'] == 'In Progress';
      }).toList();
    } else if (tabType == 'Completed') {
      filteredData = data.where((item) {
        final isArchived =
            (item['archived'] == true); // Explicit check for true
        return !isArchived && item['status'] == 'Completed';
      }).toList();
    } else {
      filteredData = [];
    }

    // Sort data by seriousness priority and latest timestamp
    filteredData.sort((a, b) {
      // Define seriousness priority
      const seriousnessPriority = {'Severe': 3, 'Moderate': 2, 'Minor': 1};

      // Get seriousness priority values (default to 0 if not defined)
      int seriousnessA = seriousnessPriority[a['seriousness']] ?? 0;
      int seriousnessB = seriousnessPriority[b['seriousness']] ?? 0;

      // Compare seriousness first
      if (seriousnessA != seriousnessB) {
        return seriousnessB.compareTo(seriousnessA); // Descending order
      }

      // If seriousness is equal, compare timestamps
      DateTime timestampA = (a['timestamp'] is Timestamp)
          ? a['timestamp'].toDate()
          : (a['timestamp'] ?? DateTime(0));

      DateTime timestampB = (b['timestamp'] is Timestamp)
          ? b['timestamp'].toDate()
          : (b['timestamp'] ?? DateTime(0));

      return timestampB.compareTo(timestampA); // Sort in descending order
    });

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _getColumns(constraints.maxWidth);
          final columnKeys = [
            "status",
            'scam',
            "primaryResponderDisplayName",
            "incidentType",
            "injuredCount",
            "seriousness",
            "timestamp",
            "actions"
          ];

          return PaginatedDataTable(
            columns: columns,
            source: LogBookDataTableSource(filteredData, columnKeys, context),
            rowsPerPage: 9,
            showCheckboxColumn: false,
            columnSpacing: 20,
          );
        },
      ),
    );
  }
}
