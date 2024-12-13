import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/logbook_download_excel_service.dart';

class DownloadDialog extends StatefulWidget {
  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final ExcelExporter excelExporter = ExcelExporter();
  bool isLoading = false;
  bool isDateRangeSelected = false;
  DateTime? startDate;
  DateTime? endDate;

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

  Future<void> _downloadData() async {
    if (isDateRangeSelected) {
      if (startDate == null || endDate == null) {
        await _showResultDialog(
          'Date Selection Required',
          'Please select both the start and end dates.',
        );
        return;
      }
      if (startDate!.isAfter(endDate!)) {
        await _showResultDialog(
          'Invalid Date Range',
          'The start date cannot be after the end date.',
        );
        return;
      }
    }
    setState(() => isLoading = true);
    // bool success;
    String result;
    if (isDateRangeSelected && startDate != null && endDate != null) {
      result = await excelExporter.downloadLogBookByDate(startDate!, endDate!);
      if (result == 'no-data-found') {
        await _showResultDialog('No Available Data to Download',
            'No data available for the selected date range.');
      }
    } else {
      result = await excelExporter.downloadLogBook();
      if (result == 'no-data-found') {
        await _showResultDialog(
            'No Available Data to Download', 'No data available for download.');
      }
    }
    setState(() => isLoading = false);
    if (result == 'success') {
      await _showResultDialog('Download Successful',
          'The logBook data has been downloaded successfully.');
      // Navigator.of(context).pop();
    } else if (result == 'something-went-wrong') {
      await _showResultDialog('Failed to Download',
          'Please try again after checking your internet connectivity.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Download Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Download All LogBook records'),
            subtitle: Text(''),
            leading: Radio<bool>(
              value: false,
              groupValue: isDateRangeSelected,
              onChanged: (value) {
                setState(() {
                  isDateRangeSelected = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Download by Date Range'),
            leading: Radio<bool>(
              value: true,
              groupValue: isDateRangeSelected,
              onChanged: (value) {
                setState(() {
                  isDateRangeSelected = value!;
                });
              },
            ),
          ),
          if (isDateRangeSelected) ...[
            ListTile(
              title: Text('Start Date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    startDate = pickedDate;
                    // Ensure endDate is valid after changing startDate
                    if (endDate != null && endDate!.isBefore(startDate!)) {
                      endDate = null; // Reset endDate if it's invalid
                    }
                  });
                }
              },
              subtitle: Text(
                startDate != null
                    ? DateFormat('yyyy-MM-dd').format(startDate!)
                    : 'Select start date',
              ),
            ),
            ListTile(
              title: Text('End Date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? (startDate ?? DateTime.now()),
                  firstDate: startDate ??
                      DateTime(2000), // Ensure startDate limits endDate
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    endDate = pickedDate;
                  });
                }
              },
              subtitle: Text(
                endDate != null
                    ? DateFormat('yyyy-MM-dd').format(endDate!)
                    : 'Select end date',
              ),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: isLoading ? null : _downloadData,
          child: isLoading ? CircularProgressIndicator() : Text('Download'),
        ),
      ],
    );
  }
}
