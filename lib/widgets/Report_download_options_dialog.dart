import 'package:flutter/material.dart';

import '../services/report_download_excel_service.dart';



class ReportDownloadDialog extends StatelessWidget {

final ReportExcelExporter excelExporter = ReportExcelExporter();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Download Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Download All Citizens Reports records'),
            leading: Radio<bool>(
              value: true,
              groupValue: true, // Always set to true as there is only one option
              onChanged: (value) {},
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
          onPressed: () async {
            await excelExporter.downloadLogBook();
            Navigator.of(context).pop();
          },
          child: Text('Download'),
        ),
      ],
    );
  }
}

// To show this dialog:
// showDialog(
//   context: context,
//   builder: (context) => DownloadDialog(onDownload: (downloadAll) {
//     // Handle download all
//   }),
// );
