import 'package:flutter/material.dart';
import 'package:isudd_attendance_monitoring/attendance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  MyApp({this.token});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: token != null ? AttendanceScreen() : LoginScreen(),
    );
  }
}
