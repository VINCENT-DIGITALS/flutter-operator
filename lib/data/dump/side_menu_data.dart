import 'package:flutter/material.dart';

import '../../Models/dump/menu_models.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.dashboard, title: 'Dashboard'),
    MenuModel(icon: Icons.receipt, title: 'Incident Reports'),
    MenuModel(icon: Icons.announcement, title: 'Announcements'),
    MenuModel(icon: Icons.sms, title: 'SMS'),
    MenuModel(icon: Icons.book, title: 'Log Book'),
    MenuModel(icon: Icons.map, title: 'Map'),
    MenuModel(icon: Icons.chat, title: 'Group Chat'),
    MenuModel(icon: Icons.people, title: 'Responders'),
    MenuModel(icon: Icons.people_outline, title: 'Citizen'),
     MenuModel(icon: Icons.logout, title: 'Sign Out'),
  ];
}
