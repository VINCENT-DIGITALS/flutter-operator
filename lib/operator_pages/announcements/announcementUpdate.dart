// announcement_update_dialog.dart

import 'package:flutter/material.dart';
import 'package:administrator/services/database_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AnnouncementUpdateDialog extends StatefulWidget {
  final String announcementId;
  final String initialTitle;
  final String initialContent;

  const AnnouncementUpdateDialog({
    Key? key,
    required this.announcementId,
    required this.initialTitle,
    required this.initialContent,
  }) : super(key: key);

  @override
  _AnnouncementUpdateDialogState createState() =>
      _AnnouncementUpdateDialogState();
}

class _AnnouncementUpdateDialogState extends State<AnnouncementUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateAnnouncement() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      bool success = await _dbService.updateAnnouncement(
        widget.announcementId,
        _titleController.text,
        _contentController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        Fluttertoast.showToast(
          msg: "Announcement updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.of(context).pop(); // Close the dialog on success
      } else {
        Fluttertoast.showToast(
          msg: "Failed to update announcement",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Announcement'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Content is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _updateAnnouncement,
          child: _isSubmitting
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text('Update'),
        ),
      ],
    );
  }
}
