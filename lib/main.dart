import 'package:administrator/services/auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'components/splash_screen.dart';
import 'firebase_options.dart';
import 'package:administrator/consts/consts.dart';
import 'package:administrator/services/weather_service.dart';

import 'operator_pages/announcement_page.dart';
import 'operator_pages/chatPage/chat_list.dart';
import 'operator_pages/citizenAccounts_page.dart';
import 'operator_pages/incident_reports_page.dart';
import 'operator_pages/logbook_page.dart';
import 'operator_pages/mapPage/map_page.dart';
import 'operator_pages/mapPage/weatherService.dart';
import 'operator_pages/responderAccount_page.dart';
import 'operator_pages/smsPage/smsPage.dart';  // Import your WeatherService here

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await GetStorage.init();

  // Initialize WeatherService to start fetching weather data periodically
  WeatherService weatherService = WeatherService();
  weatherService.startFetchingWeather();  // Start the background task for fetching weather data

  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    // Explicitly setting IndexedDB persistence for Auth on web
    await FirebaseAuth.instance.setPersistence(Persistence.INDEXED_DB);
  } catch (e) {
    print('Firebase initialization error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: SplashScreen(),  // Your home screen with splash loading
      initialRoute: '/', // Default route when the app starts
      routes: {
        '/': (context) => SplashScreen(), // Splash or initial screen
        '/auth': (context) => const AuthPage(), // Authentication page
        '/group_chat': (context) => ChatListPage(), // Group chat page
        '/Announcements':  (context) => AnnouncementManagement(),
        '/incident_reports': (context) =>IncidentReportManagementPage(),
        '/logbook': (context) =>LogBookManagementPage(),
        '/sms': (context) => SmsManagementPage(),
        '/map': (context) => MapPageMain(),
        '/responder_account': (context) =>ResponderAccountManagementPage(),
        '/citizen_accounts': (context) =>UserAccountManagementPage(),
        // Add other routes here as needed
      },
    );
  }
}
