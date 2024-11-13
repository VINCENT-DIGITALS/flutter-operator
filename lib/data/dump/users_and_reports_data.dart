
import 'package:flutter/material.dart';
import '../../Models/dump/users_and_Reports.dart';

class UsersAndReportsDetails{
  final usersAndReportsData = const [
    UsersAndReportmodel(
        icon: Icons.people_outline , value: "305", title: "Citizens"),
    UsersAndReportmodel(
        icon: Icons.people , value: "100", title: "Responders"),
    UsersAndReportmodel(
        icon: Icons.receipt, value: "10", title: "Reports"),
    UsersAndReportmodel(icon: Icons.person_off_outlined, value: "7h48m", title: "Deactivated Accnt"),
  ];
}