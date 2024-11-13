import 'package:administrator/components/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/database_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({
    super.key,
  });

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController emailController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.3, // Set width to 30% of screen width for laptop
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02), // Responsive padding
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: screenWidth * 0.02, // Responsive font size
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: screenWidth * 0.025),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.015),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.025),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () async {
                    String email = emailController.text;
                    if (email.isNotEmpty) {
                      try {
                        LoadingIndicatorDialog().show(context);
                        await _dbService.sendPasswordResetEmail(email);
                        LoadingIndicatorDialog().dismiss();

                        // Show success message
                        Fluttertoast.showToast(
                          msg: "Password reset email sent successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                      } catch (error) {
                        LoadingIndicatorDialog().dismiss();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $error")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter an email")),
                      );
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'Send',
                    style: TextStyle(fontSize: screenWidth * 0.018),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
