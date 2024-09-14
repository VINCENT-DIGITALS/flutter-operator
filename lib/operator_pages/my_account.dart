import 'dart:io';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/services/shared_pref.dart';
import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final DatabaseService _dbService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences? _prefs;
  Map<String, String> _userData = {};
  bool _isPhoneNumberRevealed = false;
  bool _isAddressRevealed = false;
  bool _isEditing = false;
  File? _image;
  String? _imageUrl;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? role;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _fetchAndDisplayUserData();
  }

  Future<void> _fetchAndDisplayUserData() async {
    try {
      setState(() {
        _userData = {
          'uid': _prefs?.getString('uid') ?? '',
          'email': _prefs?.getString('email') ?? '',
          'displayName': _prefs?.getString('displayName') ?? '',
          'photoURL': _prefs?.getString('photoURL') ?? '',
          'phoneNum': _prefs?.getString('phoneNum') ?? '',
          'createdAt': _prefs?.getString('createdAt') ?? '',
          'address': _prefs?.getString('address') ?? '',
          'status': _prefs?.getString('status') ?? '',
          'type': _prefs?.getString('type') ?? 'Admin',
        };
      });
      setState(() {
        usernameController.text = _userData['displayName'] ?? '';
        emailController.text = _userData['email'] ?? '';
        phoneController.text = _userData['phoneNum'] ?? '';
        addressController.text = _userData['address'] ?? '';
        _isEditing = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final updatedData = {
        'displayName': usernameController.text,
        'email': emailController.text,
        'phoneNum': phoneController.text,
        'address': addressController.text,
      };
      await _dbService.updateAdminUserData(
        collection: _userData['type'] ?? 'Admin',
        userId: _userData['uid'] ?? 'specificUserId',
        updatedFields: updatedData,
      );
      final prefs = await SharedPreferencesService.getInstance();
      prefs.saveUserData(updatedData);

      setState(() {
        _userData = updatedData;
        _isEditing = false;
      });

      // Fetch and display updated user data after saving
      _fetchAndDisplayUserData();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      usernameController.text = _userData['displayName'] ?? '';
      emailController.text = _userData['email'] ?? '';
      phoneController.text = _userData['phoneNum'] ?? '';
      addressController.text = _userData['address'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    String firstLetter = _userData['displayName']?.isNotEmpty == true
        ? _userData['displayName']!.substring(0, 1)
        : '';
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            isLargeScreen: isLargeScreen,
            scaffoldKey: _scaffoldKey,
            title: 'Account Profile',
          ),
          drawer: isLargeScreen
              ? null
              : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/My Account'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/My Account'),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 800),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 30,
                                      child: Text(
                                        firstLetter.isEmpty ? '?' : firstLetter,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildProfileInfoRow(
                                      title: 'Full name',
                                      controller: usernameController,
                                      content: _userData['displayName'] ?? 'No name available',
                                      hidden: false,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildProfileInfoRow(
                                      title: 'Email',
                                      controller: emailController,
                                      content: _userData['email'] ?? 'No email available',
                                      hidden: false,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildProfileInfoRow(
                                      title: 'Phone Number',
                                      controller: phoneController,
                                      content: _isPhoneNumberRevealed
                                          ? _userData['phoneNum'] ?? 'No Number available'
                                          : '**********',
                                      hidden: true,
                                      onRevealPressed: () {
                                        setState(() {
                                          _isPhoneNumberRevealed = !_isPhoneNumberRevealed;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _buildProfileInfoRow(
                                      title: 'Address',
                                      controller: addressController,
                                      content: _isAddressRevealed
                                          ? _userData['address'] ?? 'No Address available'
                                          : '**********',
                                      hidden: true,
                                      onRevealPressed: () {
                                        setState(() {
                                          _isAddressRevealed = !_isAddressRevealed;
                                        });
                                      },
                                    ),
                                    if (_isEditing)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        child: ElevatedButton(
                                          onPressed: _saveUserData,
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                          ),
                                          child: const Text('Save'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Password and Authentication',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Email verification logic
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                ),
                                child: const Text('Email Verification'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Change password logic
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                ),
                                child: const Text('Change password'),
                              ),
                            ],
                          ),
                          if (_isEditing)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(Icons.check),
                                onPressed: _saveUserData,
                              ),
                            ),
                          if (_isEditing)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: _cancelEditing,
                              ),
                            ),
                          if (!_isEditing)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoRow({
    required String title,
    required TextEditingController controller,
    required String content,
    required bool hidden,
    VoidCallback? onRevealPressed,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: _isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: title,
                  ),
                )
              : Text(content),
        ),
        if (hidden && !_isEditing)
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: onRevealPressed,
          ),
      ],
    );
  }
}
