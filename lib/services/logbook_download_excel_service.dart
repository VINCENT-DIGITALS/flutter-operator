import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:intl/intl.dart';
import 'dart:typed_data';

class ExcelExporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> downloadLogBook() async {
    // Fetch all documents in the 'logBook' collection
    final QuerySnapshot<Map<String, dynamic>> snapshot = 
        await _firestore.collection('logBook').get();

    // Create a new Excel document
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'logBook';

    // Define headers in the specified order
    final List<String> headers = [
      "timestamp",
      "updatedAt",
      "incident",
      "incidentDesc",
      "incidentType",
      "injuredCount",
      "seriousness",
      "landmark",
      "address",
      "location",
      "status",
      "scam",
      "transportedTo",
      "primaryResponderDisplayName",
      "primaryResponderId",
      "reportId",
      "reporterName",
      "responders",
      "victims",
      "vehicles",
      "mediaUrl",
    ];

    // Add headers to the first row
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    // Add document data, starting from the second row
    int rowIndex = 2;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      int columnIndex = 1;

      // Populate each header column with the appropriate data
      for (var header in headers) {
        var value = data[header];

        if (value is Timestamp) {
          // Convert Firestore Timestamp to formatted string
          final DateTime dateTime = value.toDate();
          final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
          sheet.getRangeByIndex(rowIndex, columnIndex).setText(formattedDate);
        } else if (value is Map) {
          // Convert nested map (e.g., location) to a string with key-value pairs
          sheet.getRangeByIndex(rowIndex, columnIndex).setText(
            value.entries.map((e) => '${e.key}: ${e.value}').join(', ')
          );
        } else if (value is List) {
          // Format list items (e.g., responders or victims), handling nested maps if present
          sheet.getRangeByIndex(rowIndex, columnIndex).setText(
            value.map((item) {
              if (item is Map) {
                return '{' + item.entries.map((e) => '${e.key}: ${e.value}').join(', ') + '}';
              } else {
                return item.toString();
              }
            }).join('; ')
          );
        } else if (value != null) {
          // Set simple values directly
          sheet.getRangeByIndex(rowIndex, columnIndex).setText(value.toString());
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
    final String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String name = 'logBook_$formattedDate';

    // Use FileSaver to save the file
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(bytes),
      ext: "xlsx",
      customMimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    );
    print("Excel file saved successfully as $name.");
  }
}
