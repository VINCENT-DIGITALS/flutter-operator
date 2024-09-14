// import 'package:administrator/operator_pages/operator_dashboard_page.dart';
// import 'package:flutter/material.dart';
// import 'package:administrator/services/shared_pref.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadRoleAndNavigate();
//   }

//   Future<void> _loadRoleAndNavigate() async {
//     SharedPreferencesService prefs = await SharedPreferencesService.getInstance();
//     String? role = prefs.getData('role') as String?;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomePage(role: role),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
