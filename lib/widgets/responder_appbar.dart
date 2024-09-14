import 'package:flutter/material.dart';

class ResponderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLargeScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;  // Add this line to accept the title dynamically

  ResponderAppBar({required this.isLargeScreen, required this.scaffoldKey, required this.title});

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
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
