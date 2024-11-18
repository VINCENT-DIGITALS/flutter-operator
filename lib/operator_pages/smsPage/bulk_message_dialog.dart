// import 'package:flutter/material.dart';

// class SMSComposeDialog extends StatefulWidget {
//   final List<String> phoneNumbers;

//   const SMSComposeDialog({Key? key, required this.phoneNumbers}) : super(key: key);

//   @override
//   _SMSComposeDialogState createState() => _SMSComposeDialogState();
// }

// class _SMSComposeDialogState extends State<SMSComposeDialog> {
//   final TextEditingController messageController = TextEditingController();
//   late List<String> selectedPhoneNumbers;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the selectedPhoneNumbers with all phone numbers found
//     selectedPhoneNumbers = List<String>.from(widget.phoneNumbers);
//   }

//   void _removePhoneNumber(String phoneNumber) {
//     setState(() {
//       selectedPhoneNumbers.remove(phoneNumber);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Compose Bulk SMS'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButtonFormField<String>(
//               items: widget.phoneNumbers.map((phone) {
//                 return DropdownMenuItem<String>(
//                   value: phone,
//                   child: Text(phone),
//                 );
//               }).toList(),
//               onChanged: (value) {},
//               decoration: const InputDecoration(
//                 labelText: 'Users Found',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: messageController,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 labelText: 'Message',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Selected Numbers:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: selectedPhoneNumbers.length,
//               itemBuilder: (context, index) {
//                 final phoneNumber = selectedPhoneNumbers[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Text(phoneNumber),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => _removePhoneNumber(phoneNumber),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             if (selectedPhoneNumbers.isNotEmpty &&
//                 messageController.text.trim().isNotEmpty) {
//               // Call the logic to send SMS to all selectedPhoneNumbers
//               _sendBulkSMS();
//               Navigator.pop(context);
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'Please type a message and ensure at least one recipient is selected.',
//                   ),
//                 ),
//               );
//             }
//           },
//           child: const Text('Send'),
//         ),
//       ],
//     );
//   }

//   void _sendBulkSMS() {
//     // Add your SMS sending logic here
//     // Use selectedPhoneNumbers and messageController.text
//     debugPrint('Sending SMS to: $selectedPhoneNumbers');
//     debugPrint('Message: ${messageController.text}');
//   }
// }
