import 'dart:ffi';
import 'dart:html';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_dumbbell_mobile/start_page.dart';
// import 'package:smart_dumbbell_mobile/working_page.dart';
import 'package:smart_dumbbell_mobile/me_page.dart';
import 'package:smart_dumbbell_mobile/goal_page.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:logger/logger.dart' as MyLogger;
import 'package:smart_dumbbell_mobile/progress_page.dart';


ValueNotifier<bool> isBluetoothConnected = ValueNotifier(false);
var value = '';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RepetitionsProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/me': (context) => MePage(),
        '/progress': (context) => ProgressPage(),
        '/goal': (context) => GoalPage(onGoalSelected: (int selectedIndex) {}),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    StartPage(),
    MePage(),
    ProgressPage(),
    GoalPage(onGoalSelected: (int selectedIndex) {}),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Goal',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: (index) {
          _onItemTapped(index);
          if (index == 2) { // If ProgressPage is selected
            loadActivities(context);
          }
        },
      ),
    );
  }

  void loadActivities(BuildContext context) {
    final progressPageState = context.findAncestorStateOfType<ProgressPageState>();
    progressPageState?.loadActivities();
  }
}
