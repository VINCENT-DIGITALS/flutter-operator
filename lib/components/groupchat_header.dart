import 'package:flutter/material.dart';

class GroupChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPress;
  final VoidCallback onSettingsPress;
  final String gChatname;

  const GroupChatHeader({
    Key? key,
    required this.onBackPress,
    required this.onSettingsPress,
    required this.gChatname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBackPress, // Trigger the callback when the back button is pressed
      ),
      title: Text(gChatname),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: onSettingsPress, // Trigger the settings callback
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
