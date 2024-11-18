import 'package:flutter/material.dart';

import '../operator_pages/my_account.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLargeScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final VoidCallback? onSettingsPress; // Optional callback for settings

  CustomAppBar({
    required this.isLargeScreen,
    required this.scaffoldKey,
    required this.title,
    this.onSettingsPress,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (!isLargeScreen)
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 34, 45, 67),
      elevation: 4,
      actions: [
        // IconButton(
        //   icon: Icon(Icons.notifications, color: Colors.white),
        //   onPressed: () {},
        // ),
// Wrap the IconButton with a Material widget and set color to transparent
        if (onSettingsPress !=
            null) // Show settings button if callback is provided
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Navigate back to the previous screen
                },
              ),
            ],
          ),
        Material(
          color: Colors.transparent, // Makes the background transparent
          child: IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 20.0), // Top and bottom padding for modal content
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: MyAccountPage(),
                  ),
                ),
              );
            },
          ),
        ),

        if (onSettingsPress !=
            null) // Show settings button if callback is provided
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: onSettingsPress,
              ),
            ],
          )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
