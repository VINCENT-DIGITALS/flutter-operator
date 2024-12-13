import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'pushBulletService.dart';

class UserGroupSelectionDialog extends StatefulWidget {
  @override
  _UserGroupSelectionDialogState createState() =>
      _UserGroupSelectionDialogState();
}

class _UserGroupSelectionDialogState extends State<UserGroupSelectionDialog> {
  bool isLoading = false;
  String?
      selectedGroup; // Track selected group ('citizens', 'responders', 'all')
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendSmsUsingPushbullet(
      List<String> phoneNumbers, String message) async {
    try {
      // Log the values of phoneNumber and message
      print("Phone Numbers: $phoneNumbers");
      print("Message: $message");
      setState(() => isLoading = true); // Show loading indicator

      // Create an instance of PushbulletService
      final pushbulletService = PushbulletService(
        pushbulletAccessToken:
            "o.LPC89Wi7X2uFrq2ICpScRp7i4YgtxGz5", // Replace with your token
      );

      // Call PushbulletService to send the SMS
      final result = await pushbulletService.sendSMSBulk(
        deviceIden: "ujDS8xjEV3YsjwBu3zvi3g", // Pushbullet device ID
        phoneNumbers: phoneNumbers,
        message: message,
      );

      // Handle the result
      if (result['success'] == true) {
        print(
            "SMS sent successfully: ${result['isSuccess']} phone numbers.\nFailed: ${result['numFailed']} ");
      } else {
        throw Exception("Failed to send SMS: Contact Developer or try again. ${result['error']}");
      }
    } catch (e) {
      // Check for the Pushbullet Pro error specifically
      if (e.toString().contains("Pushbullet Pro is required")) {
        // Show the error as a dialog
        _showErrorDialog(
          context,
          "Pushbullet Pro is required",
          "Pushbullet 100/month sms limit has been reached\nPushbullet Pro is required to send unlimited SMS. \nPlease upgrade your account through the PushBullet App or website.",
        );
      } else {
        // Handle other errors
        _showErrorDialog(
          context,
          "Error Sending SMS",
          "Failed to send SMS: ${e.toString()}",
        );
      }
    } finally {
      setState(() => isLoading = true); // Show loading indicator
    }
  }

// Function to show a custom error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.justify,
          ),
          content: Text(
            message,
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to display result dialog
  Future<void> _showResultDialog(String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Main SMS sending logic
  Future<void> _sendSMS() async {
    if (selectedGroup == null) {
      Fluttertoast.showToast(
        msg: "Please select a user group to proceed.",
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }
    bool? agree = await _showSMSLimitDialog(context);
    if (agree == true) {
      setState(() => isLoading = true); // Show loading indicator

      try {
        await confirmAndSend(context, userGroup: selectedGroup!);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Failed to send SMS: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
        );
      } 
    }
  }

  // Confirmation dialog with reauthentication

  Future<void> confirmAndSend(BuildContext mainContext,
      {required String userGroup}) async {
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: mainContext,
      builder: (context) => AlertDialog(
        title: Text('Enter Password to Continue'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;

              Navigator.of(context).pop(); // Close the password dialog
              if (password.isEmpty) {
                Fluttertoast.showToast(
                    msg: 'Password cannot be empty.',
                    toastLength: Toast.LENGTH_LONG);
                return;
              }

              try {
                final user = _auth.currentUser;
                if (user == null) {
                  throw Exception('User is not logged in.');
                }

                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: password,
                );

                await user.reauthenticateWithCredential(credential);
                  setState(() {
                    isLoading = true;
                  });
                // Fetch phone numbers and display the message composition dialog
                await _showBulkMessageDialog(mainContext, userGroup);
              } catch (e) {
                Fluttertoast.showToast(
                    msg: 'Failed: Wrong password',
                    toastLength: Toast.LENGTH_LONG);
              }
            },
            child: Text('Confirm', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _showBulkMessageDialog(
      BuildContext context, String userGroup) async {
    final TextEditingController messageController = TextEditingController();
    bool isSending = false; // Flag to track the sending state

    try {
      // Fetch all numbers in the group
      List<String> phoneNumbers = await _fetchPhoneNumbers(userGroup);

      // Validate phone numbers
      phoneNumbers = phoneNumbers.where(isValidPhoneNumber).toList();

      if (phoneNumbers.isEmpty) {
        Fluttertoast.showToast(
          msg: "No valid phone numbers found in the selected group.",
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.message, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Compose Bulk Message',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Phone Numbers:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showPhoneNumberDialog(context, phoneNumbers),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'View ${phoneNumbers.length} Numbers',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Message Content:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final message = messageController.text;

                      if (message.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Message cannot be empty.',
                          toastLength: Toast.LENGTH_LONG,
                        );
                        return;
                      }

                      setState(() {
                        isSending = true; // Start sending
                      });

                      try {
                        Navigator.of(context).pop(); // Close the dialog

                        bool? confirmed =
                            await _showConfirmationDialog(context);
                        if (confirmed == true) {
                          await sendSmsUsingPushbullet(phoneNumbers, message);
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Failed to send SMS: ${e.toString()}",
                          toastLength: Toast.LENGTH_LONG,
                        );
                      } finally {
                        setState(() {
                          isSending = false; // Reset sending state
                          isLoading = false; // Reset sending state
                        });
                      }
                    },
              icon: isSending
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white),
              label: isSending
                  ? Text(
                      'Sending...',
                      style: TextStyle(color: Colors.white),
                    )
                  : Text(
                      'Send',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to fetch phone numbers: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Send',
            style: TextStyle(
              color: Colors.blue, // Change color of the title
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to send the SMS to all recipients?',
            style: TextStyle(
              color: Colors.black87, // Change color of the content text
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.red, // Change color of the 'No' button text
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.black, // Change color of the 'Yes' button text
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.greenAccent, // Background color of the 'Yes' button
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showSMSLimitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PushBullet Usage!',
                style: TextStyle(
                  color: Colors.blue, // Change color of the title
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4), // Space between title and subtitle
              Text(
                'Important Notice, Pease Read it!',
                style: TextStyle(
                  color: Colors.red, // Subtitle color
                  fontSize: 14, // Smaller font size for subtitle
                ),
              ),
            ],
          ),
          content: Text(
            'If you have already upgrgaded to PushBullet Pro, ignore this message.\n\nYou are aware that PushBullet free version only allows 100/Month SMS and the messages after the limit will not send!\n\nAnd Only PushBullet Pro allows unlimited sms!',
            style: TextStyle(
              color: Colors.black87, // Change color of the content text
            ),
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.red, // Change color of the 'No' button text
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.black, // Change color of the 'Yes' button text
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.greenAccent, // Background color of the 'Yes' button
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showPhoneNumberDialog(
      BuildContext context, List<String> phoneNumbers) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: 400, // Adjusts maximum width dynamically
                maxHeight: MediaQuery.of(context).size.height *
                    0.8, // Responsive height
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phone Numbers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: phoneNumbers.isEmpty
                        ? Center(
                            child: Text(
                              "No phone numbers available.",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: phoneNumbers.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    phoneNumbers[index],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static bool isValidPhoneNumber(String number) {
    // Check for null or empty input
    if (number == null || number.trim().isEmpty) {
      return false; // Invalid input
    }

    // Sanitize the input by removing non-numeric characters except leading '+'
    number = number.replaceAll(RegExp(r'[^\d+]'), '');

    // Blacklisted or reserved numbers
    final List<String> blacklistedNumbers = ['09123456789', '09491234567'];
    if (blacklistedNumbers.contains(number) || number == '911') {
      return false; // Reject blacklisted or reserved numbers
    }

    // Auto-correct for missing '0' at the start of valid short numbers
    if (number.length == 10 && number.startsWith('9')) {
      number = '0$number';
    }

    // Handle 639XXXXXXXXX format (international without '+')
    if (number.length == 12 && number.startsWith('639')) {
      number = '+$number';
    }

    // Validate using regex for +639XXXXXXXXX or 09XXXXXXXXX
    final RegExp regex =
        RegExp(r'^(\+639|09)\d{9}$'); // Supports +639XXXXXXXXX or 09XXXXXXXXX

    if (!regex.hasMatch(number)) {
      return false; // Fail regex validation
    }

    // Ensure length is exactly 12 (+639XXXXXXXXX) or 11 (09XXXXXXXXX)
    if (number.length != 11 && number.length != 13) {
      return false;
    }

    return true; // Number is valid
  }

  static String normalizePhoneNumber(String number) {
    // Remove all non-numeric characters except '+'
    number = number.replaceAll(RegExp(r'[^\d+]'), '');

    // Handle numbers starting with '+63'
    if (number.startsWith('+63')) {
      number = '0${number.substring(3)}'; // Convert to '09XXXXXXXXX'
    }

    // Handle numbers starting with '639' (without '+')
    if (number.startsWith('639')) {
      number = '0${number.substring(2)}'; // Convert to '09XXXXXXXXX'
    }

    // Ensure numbers starting with '9' are prefixed with '0'
    if (number.length == 10 && number.startsWith('9')) {
      number = '0$number';
    }

    // Ensure the number is in '09XXXXXXXXX' format
    if (!number.startsWith('09') || number.length != 11) {
      throw FormatException('Invalid phone number format: $number');
    }

    return number;
  }

  static Future<List<String>> _fetchPhoneNumbers(String userGroup) async {
    try {
      final Set<String> phoneNumbers = {}; // Use a Set for deduplication

      if (userGroup == 'citizens') {
        final citizensSnapshot = await _firestore.collection('citizens').get();
        phoneNumbers.addAll(
          citizensSnapshot.docs
              .map((doc) => doc.data()['phoneNum'] as String?)
              .where((phoneNum) =>
                  phoneNum != null && isValidPhoneNumber(phoneNum!)) // Validate
              .map((phoneNum) => normalizePhoneNumber(phoneNum!)) // Normalize
              .cast<String>(),
        );
      } else if (userGroup == 'responders') {
        final respondersSnapshot =
            await _firestore.collection('responders').get();
        phoneNumbers.addAll(
          respondersSnapshot.docs
              .map((doc) => doc.data()['phoneNum'] as String?)
              .where((phoneNum) =>
                  phoneNum != null && isValidPhoneNumber(phoneNum!)) // Validate
              .map((phoneNum) => normalizePhoneNumber(phoneNum!)) // Normalize
              .cast<String>(),
        );
      } else if (userGroup == 'all') {
        final citizensSnapshot = await _firestore.collection('citizens').get();
        final respondersSnapshot =
            await _firestore.collection('responders').get();
        phoneNumbers.addAll(
          citizensSnapshot.docs
              .map((doc) => doc.data()['phoneNum'] as String?)
              .where((phoneNum) =>
                  phoneNum != null && isValidPhoneNumber(phoneNum!)) // Validate
              .map((phoneNum) => normalizePhoneNumber(phoneNum!)) // Normalize
              .cast<String>(),
        );
        phoneNumbers.addAll(
          respondersSnapshot.docs
              .map((doc) => doc.data()['phoneNum'] as String?)
              .where((phoneNum) =>
                  phoneNum != null && isValidPhoneNumber(phoneNum!)) // Validate
              .map((phoneNum) => normalizePhoneNumber(phoneNum!)) // Normalize
              .cast<String>(),
        );
      }

      return phoneNumbers.toList(); // Return the deduplicated list
    } catch (e) {
      throw Exception("Failed to fetch phone numbers: ${e.toString()}");
    }
  }

  static Future<void> _sendSms(String phoneNumber, String message) async {
    // Add your SMS API integration here
    await Future.delayed(Duration(seconds: 1)); // Simulate API delay
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('SMS Send Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Citizens'),
            leading: Radio<String>(
              value: 'citizens',
              groupValue: selectedGroup,
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Responders'),
            leading: Radio<String>(
              value: 'responders',
              groupValue: selectedGroup,
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('All Users'),
            leading: Radio<String>(
              value: 'all',
              groupValue: selectedGroup,
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: isLoading ? null : _sendSMS,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Confirm'),
        ),
      ],
    );
  }
}
