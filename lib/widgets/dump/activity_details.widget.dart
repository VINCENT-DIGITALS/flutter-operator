// import 'package:flutter/material.dart';

// import '../../Models/dump/responsive.dart';
// import '../../data/dump/users_and_reports_data.dart';
// import 'custom_card.dart';

// class ActivityDetailsCard extends StatelessWidget {
//   const ActivityDetailsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final usersAndReportsDetails = UsersAndReportsDetails();

//     return GridView.builder(
//       itemCount: usersAndReportsDetails.usersAndReportsData.length,
//       shrinkWrap: true,
//       physics: const ScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
//         crossAxisSpacing: Responsive.isMobile(context) ? 12 : 15,
//         mainAxisSpacing: 12.0,
//       ),
//       itemBuilder: (context, index) => CustomCard(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(
//               usersAndReportsDetails.usersAndReportsData[index].icon,
//               size: 30,
//               color: Colors.blue, // Customize color as needed
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 15, bottom: 4),
//               child: Text(
//                 usersAndReportsDetails.usersAndReportsData[index].value,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Text(
//               usersAndReportsDetails.usersAndReportsData[index].title,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
