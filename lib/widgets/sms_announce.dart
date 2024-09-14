import 'package:flutter/material.dart';

class SmsAnnouncement extends StatefulWidget {
  const SmsAnnouncement({Key? key}) : super(key: key);

  @override
  State<SmsAnnouncement> createState() => _SmsAnnouncementState();
}

class _SmsAnnouncementState extends State<SmsAnnouncement> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendSms() {
    // Implement your logic to send SMS to all registered numbers in the database
    String message = _messageController.text;

    // Example: Print the message
    print('Sending SMS with message: $message');

    // You can add more logic here, like fetching phone numbers from the database and integrating with an SMS sending service

    Navigator.of(context).pop(); // Close the dialog after sending the SMS
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create SMS Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Enter message',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter message';
              }
              // You can add more validation here if needed
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendSms,
          child: const Text('Send SMS'),
        ),
      ],
    );
  }
}

void showSmsAnnouncementDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const SmsAnnouncement();
    },
  );
}
