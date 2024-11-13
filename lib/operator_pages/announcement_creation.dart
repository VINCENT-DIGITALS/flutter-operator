import 'package:flutter/material.dart';
import 'package:administrator/services/database_service.dart';

class AnnouncementCreationDialog extends StatefulWidget {
  const AnnouncementCreationDialog({super.key});

  @override
  _AnnouncementCreationDialogState createState() => _AnnouncementCreationDialogState();
}

class _AnnouncementCreationDialogState extends State<AnnouncementCreationDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  bool _isUploading = false;

  Future<void> _createAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await _showConfirmationDialog();
      if (!confirm) return;

      setState(() {
        _isUploading = true;
      });

      Map<String, dynamic> announcementData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': DateTime.now(),
        'archived': false,
      };

      try {
        await _dbService.addAnnouncement(announcementData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create announcement.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text('Are you done?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double dialogHeight = screenSize.height < 600 ? screenSize.height * 0.75 : screenSize.height * 0.55;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: BoxConstraints(
          maxHeight: dialogHeight,
          maxWidth: screenSize.width * 0.25,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Create Announcement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                      onFieldSubmitted: (_) {
                        _titleFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(_contentFocusNode);
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        labelStyle: const TextStyle(color: Colors.grey),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Content is required' : null,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _createAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: _isUploading ? 0 : 5,
                        shadowColor: _isUploading ? Colors.transparent : Colors.black26,
                      ),
                      child: _isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                                SizedBox(width: 12.0),
                                Text('Uploading...', style: TextStyle(fontSize: 16.0)),
                              ],
                            )
                          : const Text('Create Announcement', style: TextStyle(fontSize: 18.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
