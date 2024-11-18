import 'package:cloud_firestore/cloud_firestore.dart';

class SMSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchPhoneNumbers(String userGroup) async {
    List<String> phoneNumbers = [];

    if (userGroup == 'citizens' || userGroup == 'all') {
      final citizens = await _firestore.collection('citizens').get();
      phoneNumbers.addAll(citizens.docs.map((doc) => doc['phoneNum'].toString()));
    }

    if (userGroup == 'responders' || userGroup == 'all') {
      final responders = await _firestore.collection('responders').get();
      phoneNumbers.addAll(responders.docs.map((doc) => doc['phoneNum'].toString()));
    }

    return phoneNumbers;
  }
}
