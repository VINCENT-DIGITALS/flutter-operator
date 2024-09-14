// import 'package:administrator/widgets/appbar_navigation.dart';
// import 'package:administrator/widgets/custom_drawer.dart';
// import 'package:administrator/widgets/responder_appbar.dart';
// import 'package:administrator/widgets/responder_drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ResponderHomePage extends StatefulWidget {
//   const ResponderHomePage({super.key});

//   @override
//   State<ResponderHomePage> createState() => _ResponderHomePageState();
// }

// class _ResponderHomePageState extends State<ResponderHomePage> {
//   final user = FirebaseAuth.instance.currentUser!;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         bool isLargeScreen = constraints.maxWidth > 600;

//         return Scaffold(
//           key: _scaffoldKey,
//           appBar: ResponderAppBar(
//             isLargeScreen: isLargeScreen,
//             scaffoldKey: _scaffoldKey,
//             title: 'Dashboard',
//           ),
//           drawer: isLargeScreen
//               ? null
//               : ResponderCustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/home'),
//           body: Row(
//             children: [
//               if (isLargeScreen)
//                 Container(
//                   width: 250,
//                   child: ResponderCustomDrawer(
//                       scaffoldKey: _scaffoldKey, currentRoute: '/home'),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }


// }