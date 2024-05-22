import 'dart:math';
import 'package:smart_dumbbell_mobile/start_page.dart';
import 'package:smart_dumbbell_mobile/report_page.dart';
import 'package:smart_dumbbell_mobile/working_page.dart';
import 'package:smart_dumbbell_mobile/main.dart';

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  List<Session> sessions = [];

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  Future<void> loadActivities() async {
    final storage = ActivityStorage(); // Create an instance of ActivityStorage
    final loadedSessions = await storage.loadActivities(); // Call loadActivities from ActivityStorage
    setState(() {
      sessions = loadedSessions;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final highestRepActivity = session.reps.entries.reduce((a, b) => a.value > b.value ? a : b);
                return ActivityItem(
                  activity: highestRepActivity.key,
                  duration: session.duration,
                  reps: highestRepActivity.value.toString(),
                  calories: session.calories.toString(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String activity;
  final String duration;
  final String reps;
  final String calories;

  const ActivityItem({
    Key? key,
    required this.activity,
    required this.duration,
    required this.reps,
    required this.calories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/details');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffe1e1e1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffcff2ff),
              ),
              height: 35,
              width: 35,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/bicepcurl.jpg'), // You can change this based on the activity
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              activity,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            const Expanded(child: SizedBox()),
            const Icon(Icons.timer, size: 12),
            const SizedBox(width: 5),
            Text(
              duration,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.fitness_center, size: 12), // Changed icon to represent reps
            const SizedBox(width: 5),
            Text(
              reps,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.wb_sunny_outlined, size: 12),
            const SizedBox(width: 5),
            Text(
              calories,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class Session {
  final Map<String, double> reps;
  final String duration;
  final double calories;

  Session({required this.reps, required this.duration, required this.calories});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      reps: Map<String, double>.from(json['reps']),
      duration: json['duration'],
      calories: json['calories'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'duration': duration,
      'calories': calories,
    };
  }
}

class ActivityStorage {
  static const _keyActivities = 'activities';

  Future<void> saveActivities(List<Session> sessions) async {
    // Keep only the last 10 sessions
    final last10Sessions = sessions.length <= 10 
        ? sessions 
        : sessions.sublist(sessions.length - 10);

    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(last10Sessions.map((session) => session.toJson()).toList());
    await prefs.setString(_keyActivities, sessionsJson);
  }

  Future<List<Session>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_keyActivities);
    if (sessionsJson != null) {
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      return sessionsList.map((json) => Session.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}

void addNewSession(BuildContext context) async {
  final reps = {
    'shoulders': shoulder,
    'bicep': repetitions,
    'tricep': tricep,
  };

  final duration = elapsedTime;
  final calories = caloriesBurned;

  addSession(context, reps, duration, calories);
}


// Function to add a new session (could be called from a button press or other event)
void addSession(BuildContext context, Map<String, double> reps, String duration, double calories) async {
  final storage = ActivityStorage();
  List<Session> sessions = await storage.loadActivities();
  sessions.add(Session(reps: reps, duration: duration, calories: calories));
  await storage.saveActivities(sessions);
  final progressPageState = context.findAncestorStateOfType<ProgressPageState>();
  progressPageState?.loadActivities();
}
