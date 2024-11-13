// import 'package:flutter/material.dart';

// import '../../consts/consts.dart';
// import '../../data/dump/side_menu_data.dart';

// class SideMenuWidget extends StatefulWidget {
//   const SideMenuWidget({super.key});

//   @override
//   State<SideMenuWidget> createState() => _SideMenuWidgetState();
// }

// class _SideMenuWidgetState extends State<SideMenuWidget> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final data = SideMenuData();
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
//       color: const Color(0xFF171821),
//       child: ListView.builder(
//         itemCount: data.menu.length + 1, // +1 to account for the header
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return const Column(
//               children: [
//                 // Image placeholder
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 30,
//                       child: Text(
//                         'O',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF202D40),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Flexible(
//                       child: Text(
//                         'Operator Panel',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         overflow: TextOverflow
//                             .ellipsis, // Ellipsis if text is still too long
//                       ),
//                     ),
//                   ],
//                 ),

//                 Divider(color: Colors.grey), // Divider below text
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8.0),
//                   child: Text(
//                     "Work Space",
//                     style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             );
//           }
//           // Build menu entries
//           if (index == 7) {
//             // Below "Group Chat"
//             return Column(
//               children: [
//                 buildMenuEntry(data, index - 1),
//                 const Divider(color: Colors.grey), // Divider below Group Chat
//                 // "Manage Accounts" title
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8.0),
//                   child: Text(
//                     "Manage Accounts",
//                     style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             );
//           }
//           // Adjust index to account for header
//           return buildMenuEntry(data, index - 1);
//         },
//       ),
//     );
//   }

//   Widget buildMenuEntry(SideMenuData data, int index) {
//     final isSelected = selectedIndex == index;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.all(
//           Radius.circular(6.0),
//         ),
//         color: isSelected ? selectionColor : Colors.transparent,
//       ),
//       child: InkWell(
//         onTap: () => setState(() {
//           selectedIndex = index;
//         }),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
//               child: Icon(
//                 data.menu[index].icon,
//                 color: isSelected ? Colors.black : Colors.grey,
//               ),
//             ),
//             Text(
//               data.menu[index].title,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isSelected ? Colors.black : Colors.grey,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
