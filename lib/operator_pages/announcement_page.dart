import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:administrator/operator_pages/announcement_creation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../Models/announcement_deletio_handler.dart';
import 'announcements/announcementDialog.dart';
import 'announcements/announcementUpdate.dart';
import 'announcements/archivedAnnouncements.dart';

class AnnouncementManagement extends StatefulWidget {
  const AnnouncementManagement({super.key});

  @override
  _AnnouncementManagementState createState() => _AnnouncementManagementState();
}

class _AnnouncementManagementState extends State<AnnouncementManagement> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = "";
  late Stream<List<Map<String, dynamic>>> announcementStream;
  String role = 'Unknown';
  SharedPreferences? _prefs;
  Map<String, String> _userData = {};

  @override
  void initState() {
    super.initState();
    announcementStream = _dbService.fetchAnnouncementData();
    _initializePreferences();
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

  Future<bool> showConfirmationDialog(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm $action'),
              content:
                  Text('Are you sure you want to $action this announcement?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Confirm action and close dialog
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
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
            title: 'Announcement Management',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(
                  scaffoldKey: _scaffoldKey, currentRoute: '/Announcements'),
          body: Row(
            children: [
              if (isLargeScreen)
                SizedBox(
                  width: 250,
                  child: CustomDrawer(
                    scaffoldKey: _scaffoldKey,
                    currentRoute: '/Announcements',
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 16.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Search Bar and Delete All Button
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            // Search Bar
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search announcements',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            // SizedBox(width: 10.0),
                            // // Delete All Button
                            // ElevatedButton.icon(
                            //   onPressed: () async {
                            //     bool confirmDelete =
                            //         await showConfirmationDialog('Delete All');
                            //     if (confirmDelete) {
                            //       try {
                            //         await AnnouncementDeletionHelper();
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           SnackBar(
                            //               content: Text(
                            //                   'All announcements deleted successfully.')),
                            //         );
                            //       } catch (e) {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           SnackBar(
                            //               content: Text(
                            //                   'Error deleting all announcements: $e')),
                            //         );
                            //       }
                            //     }
                            //   },
                            //   icon: Icon(Icons.delete),
                            //   label: Text('Delete All'),
                            //   style: ElevatedButton.styleFrom(
                            //     padding: EdgeInsets.symmetric(
                            //         horizontal: 20, vertical: 10), backgroundColor: Colors
                            //         .red,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12.0),
                            //     ), // Red color to indicate deletion action
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      // Buttons
                      Wrap(
                        spacing: 10.0, // Spacing between buttons
                        runSpacing:
                            10.0, // Spacing between rows if wrapping occurs
                        alignment: WrapAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AnnouncementCreationDialog();
                                },
                              );
                            },
                            icon: Icon(Icons.add, color: Colors.black),
                            label: Text(
                              'Create Announcement',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ArchivedAnnouncementManagement(),
                                ),
                              );
                            },
                            icon: Icon(Icons.archive_rounded,
                                color: Colors.black),
                            label: Text(
                              'Archived Announcements',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              bool confirmDelete =
                                  await showConfirmationDialog('Delete All');
                              if (confirmDelete) {
                                try {
                                  // Call the deletion helper to delete all announcements
                                  await AnnouncementDeletionHelper
                                      .initialConfirmation(context);

                                  // Display success message
                                } catch (e) {
                                  // Display error message if deletion fails
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error deleting all announcements: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.black),
                            label: Text(
                              'Delete All',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor: Colors
                                  .red, // Red color to indicate deletion action
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.0),
                      // Announcements List/Grid
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: announcementStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text('No announcements found.'));
                            } else {
                              var filteredData =
                                  snapshot.data!.where((announcement) {
                                return announcement['title']
                                        .toLowerCase()
                                        .contains(_searchQuery.toLowerCase()) ||
                                    announcement['content']
                                        .toLowerCase()
                                        .contains(_searchQuery.toLowerCase());
                              }).toList();

                              return _buildAnnouncementsGrid(
                                  filteredData, isLargeScreen);
                            }
                          },
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

  Widget _buildAnnouncementsGrid(
      List<Map<String, dynamic>> data, bool isLargeScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isLargeScreen ? 20.0 : 10.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isLargeScreen ? 400.0 : 300.0,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: isLargeScreen ? 2 / 1 : 3 / 2,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final announcement = data[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AnnouncementDetailDialog(
                title: announcement['title'] ?? '',
                content: announcement['content'] ?? '',
                timestamp: announcement['timestamp'].toDate(),
              ),
            );
          },
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          announcement['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isLargeScreen ? 16.0 : 14.0,
                            color: Colors.blue[900],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String result) async {
                          if (result == 'Update') {
                            bool confirmed =
                                await showConfirmationDialog('Update');
                            if (confirmed) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AnnouncementUpdateDialog(
                                    announcementId: announcement['id'],
                                    initialTitle: announcement['title'] ?? '',
                                    initialContent:
                                        announcement['content'] ?? '',
                                  );
                                },
                              );
                            }
                          } else if (result == 'Archive') {
                            bool confirmed =
                                await showConfirmationDialog('archive');
                            if (confirmed) {
                              try {
                                await _dbService
                                    .archiveAnnouncement(announcement['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Announcement archived successfully.')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error archiving announcement: $e')),
                                );
                              }
                            }
                          } else if (result == 'Delete') {
                            bool confirmDelete =
                                await showConfirmationDialog('delete');
                            if (confirmDelete) {
                              try {
                                await _dbService
                                    .deleteAnnouncement(announcement['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Announcement deleted successfully.')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error deleting announcement: $e')),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'Update',
                            child: Text('Update'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Archive',
                            child: Text('Archive'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: Text(
                      announcement['content'] ?? '',
                      maxLines: isLargeScreen ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 14.0 : 12.0,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatTimestamp(announcement['timestamp']),
                      style: TextStyle(
                        fontSize: isLargeScreen ? 12.0 : 10.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
