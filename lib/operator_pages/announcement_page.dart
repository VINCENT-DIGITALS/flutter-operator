import 'package:administrator/widgets/videoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:administrator/operator_pages/announcement_creation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  

  void _showMediaDialog(List<String> fileUrls, List<String> fileTypes, int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                constraints: BoxConstraints(
                  maxWidth: 700.0, // Set the maximum width constraint
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: currentIndex > 0
                              ? () {
                                  setState(() {
                                    currentIndex--;
                                  });
                                }
                              : null,
                        ),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.6,
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey, // Set the border color
                                width: 1.0, // Set the border width
                              ),
                              borderRadius: BorderRadius.circular(8.0), // Set the border radius
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: fileTypes[currentIndex] == 'mp4'
                                  ? VideoPlayerWidget(url: fileUrls[currentIndex])
                                  : Image.network(
                                      fileUrls[currentIndex],
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: currentIndex < fileUrls.length - 1
                              ? () {
                                  setState(() {
                                    currentIndex++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMediaRow(List<dynamic> fileUrls, List<dynamic> fileTypes) {
    return Row(
      children: List.generate(fileUrls.length > 3 ? 3 : fileUrls.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Stack(
              children: [
                _buildMedia(fileUrls, fileTypes, index),
                if (index == 2 && fileUrls.length > 3)
                  Positioned.fill(
                    child: InkWell(
                      onTap: () => _showMediaDialog(fileUrls.cast<String>(), fileTypes.cast<String>(), 2),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Text(
                            '+${fileUrls.length - 3}',
                            style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMedia(List<dynamic> fileUrls, List<dynamic> fileTypes, int index) {
    return InkWell(
      onTap: () => _showMediaDialog(fileUrls.cast<String>(), fileTypes.cast<String>(), index),
      child: fileTypes[index] == 'png' || fileTypes[index] == 'jpg'
          ? Image.network(
              fileUrls[index],
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            )
          : Container(
              height: 100,
              width: double.infinity,
              child: VideoPlayerWidget(url: fileUrls[index]),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 700;

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            isLargeScreen: isLargeScreen,
            scaffoldKey: _scaffoldKey,
            title: 'Announcement Management',
          ),
          drawer: isLargeScreen ? null : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/Announcements'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/Announcements'),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: isLargeScreen ? 400 : double.infinity,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
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
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AnnouncementCreationDialog();
                              },
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Create Announcement'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // Button text color
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: announcementStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('No announcements found.'));
                            } else {
                              var filteredData = snapshot.data!.where((announcement) {
                                return announcement['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                    announcement['content'].toLowerCase().contains(_searchQuery.toLowerCase());
                              }).toList();

                              return _buildAnnouncementsGrid(filteredData, isLargeScreen);
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

  Widget _buildAnnouncementsGrid(List<Map<String, dynamic>> data, bool isLargeScreen) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isLargeScreen ? 400.0 : 300.0, // Maximum width of each grid item
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: isLargeScreen ? 2 / 1 : 3 / 2, // Adjust this for card aspect ratio
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final announcement = data[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String result) async {
                        if (result == 'Update') {
                          // Show a form to update the announcement
                        } else if (result == 'Archive') {
                          await _dbService.archiveAnnouncement(announcement['id']);
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
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                if (announcement['fileUrls'] != null && announcement['fileUrls'].isNotEmpty)
                  Container(
                    height: 100.0, // Fix the height of the media row
                    child: _buildMediaRow(announcement['fileUrls'], announcement['fileTypes']),
                  ),
                SizedBox(height: 8.0),
                Expanded(
                  child: Text(
                    announcement['content'] ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  announcement['timestamp']?.toDate().toString() ?? '',
                  style: TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
