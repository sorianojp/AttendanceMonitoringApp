import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_screen.dart'; // Make sure to import your LoginScreen

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> _attendances = [];
  bool _isLoading = true; // To track loading state
  String? _errorMessage; // To track any error message

  @override
  void initState() {
    super.initState();
    _fetchAttendances();
  }

  Future<void> _fetchAttendances() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
          'http://146.190.99.93/api/attendances'), // Replace with your API URL
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _attendances = json.decode(response.body);
        _isLoading = false; // Stop loading
      });
    } else {
      setState(() {
        _isLoading = false; // Stop loading
        _errorMessage =
            'Failed to load attendances. Please try again.'; // Set error message
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear token

    // Navigate back to the login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    await _fetchAttendances(); // Fetch attendances again
  }

  @override
  Widget build(BuildContext context) {
    // Define the date format
    final DateFormat dateFormat = DateFormat('MMMM dd, yyyy hh:mm a');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('My Students'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Callback for pull to refresh
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Loading indicator
            : _errorMessage != null // Show error message if exists
                ? Center(child: Text(_errorMessage!))
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: _attendances.length,
                      itemBuilder: (context, index) {
                        final attendance =
                            _attendances[_attendances.length - 1 - index];
                        final lastName = attendance['student']['lastname'];
                        final firstName = attendance['student']['firstname'];

                        // Parse the entry time
                        final DateTime entryTime =
                            DateTime.parse(attendance['entry_time']);
                        final String formattedEntryTime =
                            dateFormat.format(entryTime);

                        // Handle potential null exit_time
                        final String formattedExitTime =
                            attendance['exit_time'] != null
                                ? dateFormat.format(
                                    DateTime.parse(attendance['exit_time']))
                                : '--'; // Default message for null exit_time

                        final status = attendance['status'];
                        return Card(
                          elevation:
                              0, // Adjust the elevation for the shadow effect
                          margin: EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 4.0), // Adjust margins as needed
                          child: Padding(
                            padding: EdgeInsets.all(
                                16.0), // Adjust padding as needed (all sides)
                            child: ListTile(
                              title: Text(
                                '$lastName, $firstName',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Make the title bold
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Entry: ', // Label for Entry
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.black), // Bold and black
                                    ),
                                    TextSpan(
                                      text:
                                          '$formattedEntryTime\n', // Entry time
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black), // Normal weight
                                    ),
                                    TextSpan(
                                      text: 'Exit: ', // Label for Exit
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.black), // Bold and black
                                    ),
                                    TextSpan(
                                      text: '$formattedExitTime', // Exit time
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black), // Normal weight
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Text(
                                '$status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: status == 'In'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
