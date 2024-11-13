import 'dart:io';

import 'package:administrator/login_page/login_page.dart';
import 'package:administrator/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:administrator/models/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');

  // Check if user is authenticated
  bool _isAuthenticated() {
    return _auth.currentUser != null;
  }

  Future<QuerySnapshot> getResponderByEmail(String email) {
    return _db.collection('responders').where('email', isEqualTo: email).get();
  }

  Future<QuerySnapshot> getOperatorByEmail(String email) {
    return _db.collection('operator').where('email', isEqualTo: email).get();
  }

  // Upload file (image or video) and get URL
  Future<String> uploadFile(File file, String folder) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print('File uploaded successfully: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Error uploading file: Upload failed');
      }
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> fetchPostData() {
    return _db.collection('posts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data()..['id'] = doc.id;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> fetchAnnouncementData() {
    return _db
        .collection('announcements')
        .where('archived', isEqualTo: false)
        .orderBy('timestamp',
            descending: true) // Order by timestamp in descending order
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data()..['id'] = doc.id;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> fetchArchivedAnnouncementData() {
    return _db
        .collection('announcements')
        .where('archived', isEqualTo: true)
        .orderBy('timestamp',
            descending: true) // Order by timestamp in descending order
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data()..['id'] = doc.id;
      }).toList();
    });
  }

  // Add announcement
  Future<void> addAnnouncement(Map<String, dynamic> announcementData,
      {File? file, String? folder}) async {
    try {
      if (file != null && folder != null) {
        String fileUrl = await uploadFile(file, folder);
        announcementData['fileUrl'] = fileUrl;
      }
      await _db.collection('announcements').add(announcementData);
      print('Announcement added: $announcementData');
    } catch (e) {
      print('Error adding announcement: $e');
      throw Exception('Error adding announcement: $e');
    }
  }

  // Update announcement
  Future<bool> updateAnnouncement(
      String id, String title, String content) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .update({
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Announcement updated successfully');
      return true; // Return true if successful
    } catch (e) {
      print('Error updating announcement: $e');
      return false; // Return false if there was an error
    }
  }

  // Archive announcement
  Future<void> archiveAnnouncement(String id) async {
    try {
      await _db.collection('announcements').doc(id).update({'archived': true});
      print('Announcement archived: $id');
    } catch (e) {
      print('Error archiving announcement: $e');
      throw Exception('Error archiving announcement: $e');
    }
  }

  // Archive announcement
  Future<void> UnarchiveAnnouncement(String id) async {
    try {
      await _db.collection('announcements').doc(id).update({'archived': false});
      print('Announcement archived: $id');
    } catch (e) {
      print('Error archiving announcement: $e');
      throw Exception('Error archiving announcement: $e');
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcementId)
        .delete();
  }

  // Add post
  Future<void> addPost(Map<String, dynamic> postData,
      {File? file, String? folder}) async {
    try {
      if (file != null && folder != null) {
        String fileUrl = await uploadFile(file, folder);
        postData['fileUrl'] = fileUrl;
      }
      await _db.collection('posts').add(postData);
      print('Post added: $postData');
    } catch (e) {
      print('Error adding post: $e');
      throw Exception('Error adding post: $e');
    }
  }

  // Update post
  Future<void> updatePost(String id, Map<String, dynamic> postData) async {
    try {
      await _db.collection('posts').doc(id).update(postData);
      print('Post updated: $postData');
    } catch (e) {
      print('Error updating post: $e');
      throw Exception('Error updating post: $e');
    }
  }

  // Archive post
  Future<void> archivePost(String id) async {
    try {
      await _db.collection('posts').doc(id).update({'archived': true});
      print('Post archived: $id');
    } catch (e) {
      print('Error archiving post: $e');
      throw Exception('Error archiving post: $e');
    }
  }

  // Check if the current user is an operator
  Future<bool> _isOperator() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _db.collection('operator').doc(user.uid).get();
    return doc.exists;
  }

  // Check if an email belongs to either operator or responder
  Future<bool> isAuthorizedEmail(String email) async {
    final operatorQuery =
        _db.collection('operator').where('email', isEqualTo: email).get();

    final results = await Future.wait([operatorQuery]);
    final isOperator = results[0].docs.isNotEmpty;

    // Ensure the email is present in only one collection
    if (!isOperator) {
      print('Error: Account does not exist in Operators.');
      return false; // Email should not belong to both collections
    }
    return isOperator;
  }

  // Getter for the current user
  User? get currentUser {
    return _auth.currentUser;
  }

  Future<UserCredential> registerWithEmailAndPassword(String email,
      String password, String displayName, String phoneNumber) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _createUserDocumentIfNotExists(
        userCredential.user, displayName, phoneNumber);

    return userCredential;
  }

// Check if email exists in the responders collection
  Future<bool> checkIfEmailExists(String email) async {
    final querySnapshot = await _db
        .collection("responders")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

// Create user document in Firestore if it doesn't already exist
  Future<void> _createUserDocumentIfNotExists(User? user,
      [String? displayName, phoneNumber]) async {
    if (user != null) {
      final userDoc = _db.collection("responders").doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        final userInfoMap = {
          'uid': user.uid,
          'email': user.email,
          'displayName': displayName ?? user.displayName,
          'photoURL': user.photoURL,
          'phoneNum': phoneNumber ?? user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'address': '',
          'type': 'Responder',
          'status': 'Activated',
        };

        await userDoc.set(userInfoMap);
      }
    }
  }

  // Method to fetch current user data once
  Future<Map<String, dynamic>> fetchCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('operator')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No data available for the current user');
      }

      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return userData;
    } catch (e) {
      // Handle errors
      throw Exception('Error fetching user data: $e');
    }
  }

// Method to fetch user data with "createdAt" and "email" fields
  Stream<List<Map<String, dynamic>>> fetchUserData() {
    return _db
        .collection('citizens')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                "id": doc.id,
                "name": doc.data().containsKey('displayName')
                    ? doc.get('displayName')
                    : 'Unknown',
                "phone number": doc.data().containsKey('phoneNum')
                    ? doc.get('phoneNum')
                    : 'Unknown',
                "status": doc.data().containsKey('status')
                    ? doc.get('status')
                    : 'Unknown',
                "email": doc.data().containsKey('email')
                    ? doc.get('email')
                    : 'Unknown', // Added email field
                "createdAt": doc.data().containsKey('createdAt')
                    ? doc.get('createdAt') // Assuming this is a Timestamp
                    : null, // Set to null if not available
              };
            }).toList());
  }

// Get chat messages for a specific chat with pagination
  Stream<QuerySnapshot> getMessages(String chatId, {int limit = 10}) {
    return chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<String> getDisplayName(DocumentReference senderRef) async {
    DocumentSnapshot userDoc = await senderRef.get();
    String collectionName =
        userDoc.reference.parent.id; // Get the parent collection name

    // Assuming the collection names are 'responders' or 'operators'
    if (collectionName == 'responders' || collectionName == 'operator') {
      return userDoc['displayName'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  // Method to get current user ID
  String? getCurrentUserId() {
    User? user = currentUser;
    return user?.uid; // Return UID if user is logged in, otherwise null
  }

  Future<void> sendMessage(
      String chatId, String message, String senderId, bool isOperator) async {
    var timestamp = DateTime.now();

    // Determine the correct user collection based on whether the user is an operator or responder
    CollectionReference operatorCollection =
        FirebaseFirestore.instance.collection('operator');

    try {
      // Fetch the display name
      DocumentSnapshot userDoc = await operatorCollection.doc(senderId).get();
      String displayName =
          userDoc['displayName'] ?? 'Unknown'; // Get the display name directly

      var messageData = {
        'message': message,
        'sender': operatorCollection
            .doc(senderId), // Reference the correct collection
        'timestamp': timestamp,
        'seen_by': [], // Initially no one has seen the message
        'displayName': displayName,
      };

      // Add the message to the messages subcollection
      await chats.doc(chatId).collection('messages').add(messageData);

      // Update the chat's last message details
      await chats.doc(chatId).update({
        'last_message': message,
        'last_message_time': timestamp,
        'last_message_sent_by':
            operatorCollection.doc(senderId), // Correct reference for sender
      });

      print(
          "Message sent successfully: $message"); // Success message for debugging
    } catch (e) {
      // Print the error for debugging
      print("Error sending message: $e");
    }
  }

  //
  Future<void> updateCitizenStatus(String userId, String status) async {
    try {
      await _db.collection('citizens').doc(userId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Future<void> toggleCitizenStatus(String userId, String currentStatus) async {
    String newStatus =
        currentStatus == 'Activated' ? 'Deactivated' : 'Activated';
    await updateCitizenStatus(userId, newStatus);
  }

  // Method to fetch Responder data
  Stream<List<Map<String, dynamic>>> fetchIncidentReportData() {
    return _db
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                "id": doc.id,

                "status": doc.data().containsKey('status')
                    ? doc.get('status')
                    : 'Unknown',
                "acceptedBy": doc.data().containsKey('acceptedBy')
                    ? doc.get('acceptedBy')
                    : 'Unknown',

                "incidentType": doc.data().containsKey('incidentType')
                    ? doc.get('incidentType')
                    : 'Unknown',
                "injuredCount": doc.data().containsKey('injuredCount')
                    ? doc.get('injuredCount') // Assuming this is a Timestamp
                    : null, // Set to null if not available
                "seriousness": doc.data().containsKey('seriousness')
                    ? doc.get('seriousness') // Assuming this is a Timestamp
                    : null, // Set to null if not available
                "timestamp": doc.data().containsKey('timestamp')
                    ? doc.get('timestamp')
                    : 'Unknown', // Added email field

                // "reporterId": doc.data().containsKey('reporterId')
                //     ? doc.get('reporterId') // Assuming this is a Timestamp
                //     : null, // Set to null if not available
              };
            }).toList());
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _db.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception("Error deleting report: $e");
    }
  }

  // Method to fetch Logbook  data
  Stream<List<Map<String, dynamic>>> fetchIncidentLogBookData() {
    return _db
        .collection('logBook')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                "id": doc.id,
                "status": doc.data().containsKey('status')
                    ? doc.get('status')
                    : 'Pending',
                "scam": doc.data().containsKey('scam')
                    ? doc.get('scam')
                    : 'Pending',
                "primaryResponderDisplayName":
                    doc.data().containsKey('primaryResponderDisplayName')
                        ? doc.get('primaryResponderDisplayName')
                        : 'Unknown',
                "incidentType": doc.data().containsKey('incidentType')
                    ? doc.get('incidentType')
                    : 'Unknown',
                "injuredCount": doc.data().containsKey('injuredCount')
                    ? doc.get('injuredCount')
                    : null,
                "seriousness": doc.data().containsKey('seriousness')
                    ? doc.get('seriousness')
                    : null,
                "timestamp": doc.data().containsKey('timestamp')
                    ? doc.get('timestamp') // Keep as Timestamp if available
                    : null, // Set to null if not available
              };
            }).toList());
  }

  Future<bool> deleteLogBook(String userId) async {
    try {
      // Perform the delete operation
      await _db.collection('logBook').doc(userId).delete();
      return true;
    } catch (e) {
      // Handle or log the error
      return false;
    }
  }

  // Method to fetch Responder data
  Stream<List<Map<String, dynamic>>> fetchResponderData() {
    return _db
        .collection('responders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                "id": doc.id,
                "name": doc.data().containsKey('displayName')
                    ? doc.get('displayName')
                    : 'Unknown',
                "phone number": doc.data().containsKey('phoneNum')
                    ? doc.get('phoneNum')
                    : 'Unknown',
                "status": doc.data().containsKey('status')
                    ? doc.get('status')
                    : 'Unknown',
                "email": doc.data().containsKey('email')
                    ? doc.get('email')
                    : 'Unknown', // Added email field
                "createdAt": doc.data().containsKey('createdAt')
                    ? doc.get('createdAt') // Assuming this is a Timestamp
                    : null, // Set to null if not available
              };
            }).toList());
  }

  Future<void> updateResponderStatus(String userId, String status) async {
    try {
      await _db.collection('responders').doc(userId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Future<void> toggleResponderStatus(
      String userId, String currentStatus) async {
    String newStatus =
        currentStatus == 'Activated' ? 'Deactivated' : 'Activated';
    await updateResponderStatus(userId, newStatus);
  }

  Future<Stream<QuerySnapshot>> getCitizenDetails() async {
    return await FirebaseFirestore.instance.collection('citizens').snapshots();
  }

  // Method to add a document with auto-generated ID
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
      String collectionPath, Map<String, dynamic> data) async {
    _checkAuthentication();
    return await _db.collection(collectionPath).add(data);
  }

  // Method to set a document with a specified ID (creates or overwrites)
  Future<void> setDocument(String collectionPath, String documentId,
      Map<String, dynamic> data) async {
    _checkAuthentication();
    return await _db.collection(collectionPath).doc(documentId).set(data);
  }

  // Method to update any user's document (admin only)
  Future<void> updateUserDocument(
      String userId, Map<String, dynamic> data) async {
    await _checkAdmin();
    return await _db.collection('citizens').doc(userId).update(data);
  }

  // Method to delete any user's document (admin only)
  Future<void> deleteUserDocument(String userId) async {
    await _checkAdmin();
    return await _db.collection('citizens').doc(userId).delete();
  }

  // method to save weather data (single document)
  Future<void> saveWeatherData(WeatherData weatherData) async {
    _checkAuthentication();
    String documentId = 'weatherData'; // Use a fixed document ID
    return setDocument('weather', documentId, {
      'name': weatherData.name,
      'temperature': weatherData.temperature.current,
      'humidity': weatherData.humidity,
      'windSpeed': weatherData.wind.speed,
      'feelsLike': weatherData.feelsLike,
      'pressure': weatherData.pressure,
      'seaLevel': weatherData.seaLevel,
      'weather': weatherData.weather
          .map((w) => {
                'main': w.main,
                'description': w.description,
                'icon': w.icon,
              })
          .toList(),
    });
  }

  // Private method to check authentication
  void _checkAuthentication() {
    if (!_isAuthenticated()) {
      throw Exception("User not authenticated");
    }
  }

  // Private method to check admin status
  Future<void> _checkAdmin() async {
    if (!await _isOperator()) {
      throw Exception("User is not an Operator");
    }
  }

  Future<void> updateAdminUserData({
    required String collection,
    required String userId,
    required Map<String, dynamic> updatedFields,
  }) async {
    try {
      // Validate the collection name
      if (collection != 'operator') {
        throw Exception('Invalid collection name');
      }

      final userRef = _db.collection(collection).doc(userId);
      await userRef.update(updatedFields);
    } catch (e) {
      // Handle errors
      throw Exception('Error updating admin user data: $e');
    }
  }

  //forgot password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Something went wrong: $e');
    }
  }

  void flutterToastError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void flutterToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

Reference get firebaseStorage => FirebaseStorage.instance.ref();

class FirebaseStoregeService extends GetxService {
  Future<String?> getImage(String? imgName) async {
    if (imgName == null) {
      return null;
    }
    try {
      var urlRef =
          firebaseStorage.child("post/").child('${imgName.toLowerCase()}.jpeg');
      var imgUrl = await urlRef.getDownloadURL();
      return imgUrl;
    } catch (e) {
      return null;
    }
  }
}

// To handle user account management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _dbService = DatabaseService();

  // Stream to get auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Check if the user is a responder
  Future<bool> isResponder(String email) async {
    final responderQuery = await _dbService.getResponderByEmail(email);
    return responderQuery.docs.isNotEmpty;
  }

  // Check if the user is an operator
  Future<bool> isOperator(String email) async {
    final operatorQuery = await _dbService.getOperatorByEmail(email);
    return operatorQuery.docs.isNotEmpty;
  }

  // Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      await _dbService.setDocument('users', user.uid, {
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  // Sign in with email and password (Only for authorized users)
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      // Check if the email is authorized (operator or responder)
      bool isAuthorized = await _dbService.isAuthorizedEmail(email);
      if (!isAuthorized) {
        print('Access denied. Only authorized users can sign in.');
        return 'Access denied. Only authorized users can sign in.';
      }

      // Fetch user document from Firestore
      final operatorDoc = _firestore
          .collection("operator")
          .where('email', isEqualTo: email)
          .limit(1);
      final operatordocSnapshot = await operatorDoc.get();

      Map<String, dynamic>? userData;
      String? documentId;

      if (operatordocSnapshot.docs.isNotEmpty) {
        userData = operatordocSnapshot.docs.first.data();
        documentId = operatordocSnapshot.docs.first.id;
      } else {
        return 'Account does not exist';
      }
      // final userData = docSnapshot.docs.first.data();
      // final documentId = docSnapshot.docs.first.id;
      if (userData['status'] == 'Deactivated') {
        //flutterToast('User account is deactivated, contact the operator to activate');
        return 'User account is deactivated, contact the operator to activate';
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Store user details in SharedPreferences
        SharedPreferencesService prefs =
            await SharedPreferencesService.getInstance();

        prefs.saveUserData({
          'uid': documentId ?? '',
          'email': userData['email'] ?? '',
          'displayName': userData['displayName'] ?? '',
          'photoURL': userData['photoURL'] ?? '',
          'phoneNum': userData['phoneNum'] ?? '',
          'createdAt':
              (userData['createdAt'] as Timestamp).toDate().toIso8601String(),
          'address': userData['address'] ?? '',
          'type': userData['type'] ?? '',
          'status': userData['status'] ?? '',
        });

        print('User data saved in SharedPreferences');
      }
      return null; // Sign-in successful
    } on FirebaseAuthException catch (e) {
      print('Caught FirebaseAuthException: ${e.code}');
      print('Error message: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          //('User not found');
          print('Something went wrong: $e');
          return 'User not found';
        //break;
        case 'invalid-credential':
          //flutterToastError('Incorrect password');
          print('Something went wrong: $e');
          return 'Incorrect password';
        //break;
        case 'user-disabled':
          //flutterToastError('User account has been disabled');\
          print('Something went wrong: $e');
          return 'User account has been disabled';
        //break;
        case 'invalid-email':
          //flutterToast('The email address is not valid.');
          print('Something went wrong: $e');
          return 'The email address is not valid.';
        default:
          //flutterToastError('Something went wrong, please try again');
          print('Something went wrong: $e');
          return 'Something went wrong, please try again';
        //break;
      }
      throw (e.code);
    } catch (e) {
      print('Something went wrong: $e');
      //flutterToastError('Something went wrong, please try again');
      return 'Something went wrong, please try again';
      //throw Exception('Something went wrong: $e');
    }
  }

  // Removing a specific key
  void removeKey(String key) {
    final storage = GetStorage();
    storage.remove(key);
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();

    // Clear any local storage if used (e.g., SharedPreferences)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    removeKey('role'); // Clear any local storage if used (e.g., get_storage)
    final storage = GetStorage();
    storage.erase(); // Clear all stored data

    // Reset any state management variables if used
    // Example: Resetting a user provider or similar state management variables
    // Provider.of<UserProvider>(context, listen: false).resetUser();

    // Navigate to the login page and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Update another user's account (admin only)
  Future<void> updateUserAccount(
      String userId, Map<String, dynamic> data) async {
    await _dbService.updateUserDocument(userId, data);
  }

  // Delete another user's account (admin only)
  Future<void> deleteUserAccount(String userId) async {
    await _dbService.deleteUserDocument(userId);
  }
}
