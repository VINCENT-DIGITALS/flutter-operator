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

import 'Sms_report_table.dart';

class SmsManagementPage extends StatefulWidget {
  const SmsManagementPage({super.key});

  @override
  _SmsManagementPageState createState() =>
      _SmsManagementPageState();
}

class _SmsManagementPageState
    extends State<SmsManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _dbService =
      DatabaseService(); // Instantiate DatabaseService
  String _searchQuery = "";
  late Stream<List<Map<String, dynamic>>> userStream;
  String role = 'Unknown';

  @override
  void initState() {
    super.initState();
    userStream = _dbService
        .fetchIncidentReportData(); // Fetch user data from DatabaseService
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if screen width is larger than 600 pixels
        bool isLargeScreen = constraints.maxWidth > 700;

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            isLargeScreen: isLargeScreen,
            scaffoldKey: _scaffoldKey,
            title: 'Report Managements',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(
                  scaffoldKey: _scaffoldKey, currentRoute: '/incident_reports'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(
                      scaffoldKey: _scaffoldKey,
                      currentRoute: '/incident_reports'),
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
  List<DataColumn> _getColumns(double width) {
    return [
      DataColumn(label: Text('Status')),
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
      length: 1,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Incident Reports'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildIncentReportsTable(filteredData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncentReportsTable(List<Map<String, dynamic>> filteredData) {
    // Filter and sort data based on conditions
    List<Map<String, dynamic>> nonCompletedReports =
        filteredData.where((item) => item['status'] != 'Completed').toList();

    List<Map<String, dynamic>> completedReports =
        filteredData.where((item) => item['status'] == 'Completed').toList();

// Sort each group by latest timestamp
    nonCompletedReports.sort((a, b) {
      DateTime timestampA = (a['timestamp'] is Timestamp)
          ? a['timestamp'].toDate()
          : (a['timestamp'] ?? DateTime(0));

      DateTime timestampB = (b['timestamp'] is Timestamp)
          ? b['timestamp'].toDate()
          : (b['timestamp'] ?? DateTime(0));

      return timestampB.compareTo(timestampA); // Sort in descending order
    });

    completedReports.sort((a, b) {
      DateTime timestampA = (a['timestamp'] is Timestamp)
          ? a['timestamp'].toDate()
          : (a['timestamp'] ?? DateTime(0));

      DateTime timestampB = (b['timestamp'] is Timestamp)
          ? b['timestamp'].toDate()
          : (b['timestamp'] ?? DateTime(0));

      return timestampB.compareTo(timestampA); // Sort in descending order
    });

// Combine both lists, prioritizing non-completed reports
    List<Map<String, dynamic>> sortedData =
        nonCompletedReports + completedReports;

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _getColumns(constraints.maxWidth);
          final columnKeys = [
            "status",
            "acceptedBy",
            "incidentType",
            "injuredCount",
            "seriousness",
            "timestamp",
            "actions"
          ];

          return PaginatedDataTable(
            columns: columns,
            source:
                SmsDataTableSource(sortedData, columnKeys, context),
            rowsPerPage:9,
            showCheckboxColumn: false,
            columnSpacing: 20,
          );
        },
      ),
    );
  }

}
