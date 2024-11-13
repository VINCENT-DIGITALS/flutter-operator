import 'dart:io';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/forgot_password.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

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
  bool _isLoading = false;
  File? _image;
  String? _imageUrl;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  void _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _fetchAndDisplayUserData();
  }

  Future<void> _fetchAndDisplayUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId != null) {
      setState(() {
        _userData = {
          'uid': userId,
          'email': _prefs?.getString('email') ?? '',
          'displayName': _prefs?.getString('displayName') ?? '',
          'phoneNum': _prefs?.getString('phoneNum') ?? '',
          'address': _prefs?.getString('address') ?? '',
        };
        usernameController.text = _userData['displayName'] ?? '';
        emailController.text = _userData['email'] ?? '';
        phoneController.text = _userData['phoneNum'] ?? '';
        addressController.text = _userData['address'] ?? '';
      });
    } else {
      print('User is not logged in');
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updatedData = {
        'displayName': usernameController.text,
        'email': emailController.text,
        'phoneNum': phoneController.text,
        'address': addressController.text,
      };

      final userId = _userData['uid'] ?? 'defaultUserId';
      await _dbService.updateAdminUserData(
        collection: 'operator',
        userId: userId,
        updatedFields: updatedData,
      );

      final prefs = await SharedPreferencesService.getInstance();
      prefs.saveUserData(updatedData);

      setState(() {
        _userData = updatedData;
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data updated successfully!')),
      );
      _fetchAndDisplayUserData();
    } catch (e) {
      print('Error saving user data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user data: $e')),
      );
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
        : '?';

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('My Account'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelEditing,
              ),
          ],
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width > 500
                      ? 400
                      : double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        12), // Rounded edges for the container
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset:
                            const Offset(0, 3), // Adds shadow to the container
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade50,
                            radius: 50,
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                  fontSize: 40, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._buildProfileInfoCards(),
                      const SizedBox(height: 20),
                      if (_isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _saveUserData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor:
                                    Colors.white, // Set text color here
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                            OutlinedButton(
                              onPressed: _cancelEditing,
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      _buildAccountManagementCard(),
                    ],
                  ),
                ),
              )),
        ),
        floatingActionButton: !_isEditing
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.edit),
              )
            : null,
      ),
    );
  }

  List<Widget> _buildProfileInfoCards() {
    return [
      _buildProfileInfoCard(
        'Full Name',
        usernameController,
        _userData['displayName'] ?? 'Not available',
      ),
      _buildProfileInfoCard(
        'Email',
        emailController,
        _userData['email'] ?? 'Not available',
        isEmail: true,
      ),
      _buildProfileInfoCard(
        'Phone Number',
        phoneController,
        _isPhoneNumberRevealed
            ? _userData['phoneNum'] ?? 'Not available'
            : '**********',
        hidden: true,
        onRevealPressed: () {
          setState(() {
            _isPhoneNumberRevealed = !_isPhoneNumberRevealed;
          });
        },
      ),
      _buildProfileInfoCard(
        'Address',
        addressController,
        _isAddressRevealed
            ? _userData['address'] ?? 'Not available'
            : '**********',
        hidden: true,
        onRevealPressed: () {
          setState(() {
            _isAddressRevealed = !_isAddressRevealed;
          });
        },
      ),
    ];
  }

  Widget _buildProfileInfoCard(
    String title,
    TextEditingController controller,
    String content, {
    bool hidden = false,
    VoidCallback? onRevealPressed,
    bool isEmail = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: _isEditing && !isEmail
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: title,
                      ),
                    )
                  : Text(
                      content,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            if (hidden && !_isEditing)
              IconButton(
                icon:
                    const Icon(Icons.visibility, size: 20, color: Colors.green),
                onPressed: onRevealPressed,
              ),
          ],
        ),
      ),
    );
  }

// Method to create the Account Management card with Change Password button
  Widget _buildAccountManagementCard() {
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account Management',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Show ForgotPasswordDialog when the button is pressed
                  showDialog(
                    context: context,
                    builder: (context) => const ForgotPasswordDialog(),
                  );
                },
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
