import 'package:flutter/material.dart';
import 'dart:convert';
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
    final storage = ActivityStorage();
    final loadedSessions = await storage.loadActivities();
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
              // Reverse the index to display the newest activities first
              final session = sessions.reversed.toList()[index];
              final highestRepActivity = session.reps.entries.reduce((a, b) => a.value > b.value ? a : b);
              
              // Check if all reps are 0 or if all rep values are the same
              final allZeroReps = session.reps.values.every((value) => value == 0);
              final sameReps = session.reps.values.toSet().length == 1;
              
              // If all reps are 0 or all rep values are the same, set the highest rep activity to "bicep"
              final activity = (allZeroReps || sameReps) ? 'bicep' : highestRepActivity.key;
              
              return ActivityItem(
                activity: activity,
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
                    image: AssetImage('assets/bicepcurl.jpg'),
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
            const Icon(Icons.fitness_center, size: 12),
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
      reps: (json['reps'] as Map<String, dynamic>).map((key, value) => MapEntry(key, num.parse(value.toString()).toDouble())),
      duration: json['duration'],
      calories: num.parse(json['calories'].toString()).toDouble(),
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