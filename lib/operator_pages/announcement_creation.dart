import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:administrator/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

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
  List<File> _selectedFiles = [];
  List<String> _fileTypes = [];
  List<Uint8List> _webImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImages = result.files.map((file) => file.bytes!).toList();
          _fileTypes = result.files.map((file) => file.extension!).toList();
        });
      } else {
        setState(() {
          _selectedFiles = result.files.map((file) => File(file.path!)).toList();
          _fileTypes = result.files.map((file) => file.extension!).toList();
        });
      }
    } else {
      print('No file selected');
    }
  }

  Future<String> _uploadFileWithProgress(File file, String folder, String fileType) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/$fileType'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _uploadProgress = progress;
        });
        print('Upload progress: $progress%');
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('File uploaded: $fileName');
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<String> _uploadWebImageWithProgress(Uint8List webImage, String folder, String fileType) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putData(
        webImage,
        SettableMetadata(contentType: 'image/$fileType'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _uploadProgress = progress;
        });
        print('Upload progress: $progress%');
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('File uploaded: $fileName');
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> _createAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await _showConfirmationDialog();
      if (!confirm) return;

      setState(() {
        _isUploading = true;
      });

      List<String> fileUrls = [];
      List<String> fileTypes = [];

      for (int i = 0; i < _selectedFiles.length; i++) {
        String fileUrl = await _uploadFileWithProgress(_selectedFiles[i], 'announcements', _fileTypes[i]);
        fileUrls.add(fileUrl);
        fileTypes.add(_fileTypes[i]);
      }

      for (int i = 0; i < _webImages.length; i++) {
        String fileUrl = await _uploadWebImageWithProgress(_webImages[i], 'announcements', _fileTypes[i]);
        fileUrls.add(fileUrl);
        fileTypes.add(_fileTypes[i]);
      }

      Map<String, dynamic> announcementData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'fileUrls': fileUrls,
        'fileTypes': fileTypes,
        'archived': false,
      };

      await _dbService.addAnnouncement(announcementData);
      print('Announcement created: $announcementData');

      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });

      Navigator.pop(context);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you done?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    )) ?? false;
  }

  void _handleKeyEvent(RawKeyEvent event, TextEditingController controller) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
      final value = controller.value;
      final newText = value.text.replaceRange(
        value.selection.start,
        value.selection.end,
        '\t',
      );
      final newSelection = value.selection.copyWith(
        baseOffset: value.selection.start + 1,
        extentOffset: value.selection.start + 1,
      );
      controller.value = value.copyWith(
        text: newText,
        selection: newSelection,
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileTypes.removeAt(index);
    });
  }

  void _removeWebImage(int index) {
    setState(() {
      _webImages.removeAt(index);
      _fileTypes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool isLargeScreen = constraints.maxWidth > 600;
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 111, 111, 111),
                  Color.fromARGB(255, 128, 128, 128)
                ],
              ),
            ),
            child: isLargeScreen
                ? Row(
                    children: [
                      Expanded(flex: 2, child: _buildForm()),
                      SizedBox(width: 16.0),
                      Expanded(flex: 1, child: _buildPreview()),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildForm(),
                        SizedBox(height: 16.0),
                        _buildPreview(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _pickFile,
                child: Container(
                  width: 80,
                 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Icon(Icons.camera_alt, size: 40, color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: const InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Title is required';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              _titleFocusNode.unfocus();
              FocusScope.of(context).requestFocus(_contentFocusNode);
            },
          ),
          const SizedBox(height: 16.0),
          RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _handleKeyEvent(event, _contentController),
            child: TextFormField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Content is required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _isUploading ? null : _createAnnouncement,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C52FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: _isUploading
                ? Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8.0),
                      Text('${_uploadProgress.toStringAsFixed(2)}% Uploaded'),
                    ],
                  )
                : const Text(
                    'Create Announcement',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder(
          valueListenable: _titleController,
          builder: (context, TextEditingValue value, __) {
            return Text(
              'Title Preview: ${value.text}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 8.0),
        ValueListenableBuilder(
          valueListenable: _contentController,
          builder: (context, TextEditingValue value, __) {
            return Text(
              'Content Preview: ${value.text}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            );
          },
        ),
        const SizedBox(height: 16.0),
        const Text(
          'Selected Files:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        _selectedFiles.isNotEmpty || _webImages.isNotEmpty
            ? Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ..._selectedFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    File file = entry.value;
                    return Stack(
                      children: [
                        Image.file(
                          file,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _removeFile(index),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Icon(Icons.close, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  ..._webImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    Uint8List webImage = entry.value;
                    return Stack(
                      children: [
                        Image.memory(
                          webImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _removeWebImage(index),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Icon(Icons.close, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              )
            : const Text(
                'No files selected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
      ],
    );
  }
}
