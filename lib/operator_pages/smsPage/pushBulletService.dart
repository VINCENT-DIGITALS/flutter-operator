import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class PushbulletService {
  final String pushbulletAccessToken;

  PushbulletService({required this.pushbulletAccessToken});

  // Method to send SMS to a list of phone numbers
  Future<Map<String, dynamic>> sendSMSBulk({
    required String deviceIden,
    required List<String> phoneNumbers,
    required String message,
    String? fileUrl, // Optional field for attaching an image
    bool skipDeleteFile = true, // Optional field for skip delete
  }) async {
    int isSuccess = 0;
    int numFailed = 0;
    try {
      // API Endpoint
      final url = Uri.parse("https://api.pushbullet.com/v2/texts");

      // Request Headers
      final headers = {
        "Content-Type": "application/json",
        "Access-Token": pushbulletAccessToken,
      };

      // Loop through phone numbers and send individual requests
      for (String phoneNumber in phoneNumbers) {
        final body = {
          "data": {
            "target_device_iden": deviceIden,
            "addresses": [phoneNumber], // Ensure it's a list
            "message": message,
          },
          // if (fileUrl != null) "file_url": fileUrl, // Optional file URL
          // "skip_delete_file": skipDeleteFile,
        };

        // Send POST request
        final response =
            await http.post(url, headers: headers, body: jsonEncode(body));

        if (response.statusCode == 200) {
          // Parse successful response
          final data = jsonDecode(response.body);
          print("Pushbullet API Response for $phoneNumber: $data");
          isSuccess += 1; // Show loading indicator
          // Log success in Firestore
        } else {
          // Handle API errors
          final errorData = jsonDecode(response.body);
          print("Pushbullet API Error for $phoneNumber: $errorData");

          numFailed += 1; // Show loading indicator
          // Log failure in Firestore
// Handle specific error when Pushbullet Pro is required
          if (errorData['code'] == 'pushbullet_pro_required') {
            throw Exception(
              "Pushbullet Pro is required to send SMS to $phoneNumber. Please upgrade your account.",
            );
          }
          throw Exception(
            "Failed to send SMS to $phoneNumber. Status: ${response.statusCode}, Error: ${errorData['error'] ?? 'Unknown error'}",
          );
        }
      }

      // Return success
      return {
        "success": true,
        "isSuccess": isSuccess,
        "numFailed": numFailed,
      };
    } catch (e) {
      // Log failure in Firestore
      await _logSmsToFirestore(
        message: message,
        status: "Failed",
        numSuccess: isSuccess,
        numFailed: numFailed,
      );

      // Log and propagate exceptions
      print("Error sending SMS: $e");
      return {
        "success": false,
        "error": e.toString(),
        "isSuccess": isSuccess,
        "numFailed": numFailed,
      };
    } finally {
      if (isSuccess >= 1) {
        await _logSmsToFirestore(
          message: message,
          status: "Success",
          numSuccess: isSuccess,
          numFailed: numFailed,
        );
      } else if (isSuccess <= 0) {
        await _logSmsToFirestore(
          message: message,
          status: "Failed",
          numSuccess: isSuccess,
          numFailed: numFailed,
        );
      }
    }
  }

  // Private method to log SMS activity in Firestore
  Future<void> _logSmsToFirestore({
    required String message,
    required String status,
    required int numSuccess,
    required int numFailed,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Log SMS activity to Firestore (no duplication check)
      await firestore.collection('sms').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': status,
        'numSuccess': numSuccess,
        'numFailed': numFailed,
      });
      print("SMS log saved to Firestore successfully.");
    } catch (e) {
      print("Failed to log SMS to Firestore: $e");
    }
  }
}
