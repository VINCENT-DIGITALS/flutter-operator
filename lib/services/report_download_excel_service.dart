import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:intl/intl.dart';
import 'dart:typed_data';

class ReportExcelExporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> downloadReport() async {
    try {
      // Fetch all documents in the 'logBook' collection
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('reports').get();
      if (snapshot.docs.isEmpty) {
        return 'no-data-found'; // No data to download
      }
      // Filter out documents where `archived` is true (or missing as false)
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['archived'] == null || data['archived'] == false;
      }).toList();

      if (filteredDocs.isEmpty) {
        return 'no-data-found'; // No data to download
      }
      // Sort documents by timestamp
      final sortedDocs = filteredDocs
          .where((doc) => doc.data().containsKey('timestamp'))
          .toList()
        ..sort((a, b) => (b['timestamp'] as Timestamp)
            .compareTo(a['timestamp'] as Timestamp));

      // Create a new Excel document
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Citizensreports';

      // Define headers in the specified order
      final List<String> headers = [
        "timestamp",
        "updatedAt",
        "acceptedBy",
        "address",
        "location",
        "incidentType",
        "seriousness",
        "status",
        "injuredCount",
        "incidentType",
        "landmark",
        "reporterId",
        "responderId",
        "description",
        "mediaUrl",
      ];

      // Add headers to the first row
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      // Add document data, starting from the second row
      int rowIndex = 2;
      for (var doc in sortedDocs) {
        final data = doc.data();
        int columnIndex = 1;

        // Populate each header column with the appropriate data
        for (var header in headers) {
          var value = data[header];

          if (value is Timestamp) {
            // Convert Firestore Timestamp to formatted string
            final DateTime dateTime = value.toDate();
            final formattedDate =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
            sheet.getRangeByIndex(rowIndex, columnIndex).setText(formattedDate);
          } else if (value is Map) {
            // Convert nested map (e.g., location) to a string with key-value pairs
            sheet.getRangeByIndex(rowIndex, columnIndex).setText(
                value.entries.map((e) => '${e.key}: ${e.value}').join(', '));
          } else if (value is List) {
            // Format list items (e.g., responders or victims), handling nested maps if present
            sheet
                .getRangeByIndex(rowIndex, columnIndex)
                .setText(value.map((item) {
                  if (item is Map) {
                    return '{' +
                        item.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', ') +
                        '}';
                  } else {
                    return item.toString();
                  }
                }).join('; '));
          } else if (value != null) {
            // Set simple values directly
            sheet
                .getRangeByIndex(rowIndex, columnIndex)
                .setText(value.toString());
          } else {
            // Leave cell empty if data is missing
            sheet.getRangeByIndex(rowIndex, columnIndex).setText('');
          }
          columnIndex++;
        }
        rowIndex++;
      }

      // Save workbook to bytes and trigger download
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Get current date and time for filename
      final String formattedDate =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String name = 'CitizensReports_$formattedDate';

      // Use FileSaver to save the file
      await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(bytes),
        ext: "xlsx",
        customMimeType:
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      );
      return 'success';
    } catch (e) {
      return 'something-went-wrong';
    }
  }

  Future<String> downloadReportByDate(
      DateTime startDate, DateTime endDate) async {
    try {
      final DateTime inclusiveEndDate = endDate.add(Duration(days: 1));
      // Fetch documents from the 'logBook' collection where timestamp is between startDate and endDate
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('reports')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(inclusiveEndDate))
          .get();
      if (snapshot.docs.isEmpty) {
        return 'no-data-found'; // No data to download
      }

      // Filter out documents where `archived` is true (or missing as false)
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['archived'] == null || data['archived'] == false;
      }).toList();

      if (filteredDocs.isEmpty) {
        return 'no-data-found'; // No non-archived data to download
      }

      // Sort documents by timestamp
      final sortedDocs = filteredDocs
          .where((doc) => doc.data().containsKey('timestamp'))
          .toList()
        ..sort((a, b) => (b['timestamp'] as Timestamp)
            .compareTo(a['timestamp'] as Timestamp));

      // Create a new Excel document
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Citizensreports';

      // Define headers in the specified order
      final List<String> headers = [
        "timestamp",
        "updatedAt",
        "acceptedBy",
        "address",
        "location",
        "incidentType",
        "seriousness",
        "status",
        "injuredCount",
        "incidentType",
        "landmark",
        "reporterId",
        "responderId",
        "description",
        "mediaUrl",
      ];

      // Add headers to the first row
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      // Add document data starting from the second row
      int rowIndex = 2;
      for (var doc in sortedDocs) {
        final data = doc.data();
        int columnIndex = 1;

        // Populate each header column with the appropriate data
        for (var header in headers) {
          var value = data[header];

          if (value is Timestamp) {
            final DateTime dateTime = value.toDate();
            final formattedDate =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
            sheet.getRangeByIndex(rowIndex, columnIndex).setText(formattedDate);
          } else if (value is Map) {
            sheet.getRangeByIndex(rowIndex, columnIndex).setText(
                value.entries.map((e) => '${e.key}: ${e.value}').join(', '));
          } else if (value is List) {
            sheet
                .getRangeByIndex(rowIndex, columnIndex)
                .setText(value.map((item) {
                  if (item is Map) {
                    return '{' +
                        item.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', ') +
                        '}';
                  } else {
                    return item.toString();
                  }
                }).join('; '));
          } else if (value != null) {
            sheet
                .getRangeByIndex(rowIndex, columnIndex)
                .setText(value.toString());
          } else {
            sheet.getRangeByIndex(rowIndex, columnIndex).setText('');
          }
          columnIndex++;
        }
        rowIndex++;
      }

      // Save the workbook to bytes and trigger the download
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String formattedDate =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String name = 'Citizensreports_$formattedDate';

      // Use FileSaver to save the file
      await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(bytes),
        ext: "xlsx",
        customMimeType:
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      );
      print("Excel file saved successfully as $name.");
      return 'success';
    } catch (e) {
      return 'something-went-wrong';
    }
  }
}
