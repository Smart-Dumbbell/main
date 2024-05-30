import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_dumbbell_mobile/goal_page.dart';
import 'package:smart_dumbbell_mobile/report_page.dart';
import 'package:smart_dumbbell_mobile/global.dart';
import 'package:smart_dumbbell_mobile/progress_page.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger(printer: PrettyPrinter(),);

String elapsedTime = "";

class WorkingPage extends StatefulWidget {
  final VoidCallback onEndWorkout;

  WorkingPage({required this.onEndWorkout});

  @override
  _WorkingPageState createState() => _WorkingPageState();
}

class _WorkingPageState extends State<WorkingPage> {
  late Stopwatch stopwatch;
  late Timer t;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    stopwatch.start();

    t = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (stopwatch.isRunning) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    t.cancel();
    stopwatch.stop();
    super.dispose();
  }

  String returnFormattedText() {
    final milliseconds = (stopwatch.elapsed.inMilliseconds % 1000).toString().padLeft(3, "0");
    final seconds = ((stopwatch.elapsed.inSeconds % 60)).toString().padLeft(2, "0");
    final minutes = (stopwatch.elapsed.inMinutes).toString().padLeft(2, "0");

    return "$minutes:$seconds:$milliseconds";
  }

  Future<void> endSession(BuildContext context) async {
    final reps = {
      'shoulders': shoulder_repetitions_count.toDouble(), 
      'bicep': bicep_repetitions_count.toDouble(),
      'tricep': tricep_repetitions_count.toDouble(), 
    };

    final duration = elapsedTime;
    final calories = await calculateCaloriesBurned(context);

    addSession(context, reps, duration, calories);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage()),
    );
  }

  String getElapsedTime() {
    return returnFormattedText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<RepetitionsProvider>(
                    builder: (context, repetitionsProvider, child) {
                      return Column(
                        children: [
                          if (repetitionsProvider.selectedRepetitions > 0) ...[
                            Text(
                            'Goal Repetitions: ${repetitionsProvider.selectedRepetitions}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2.5),
                            GestureDetector(
                              child: Container(
                                width: 250, // Set the desired width
                                height: 10, // Set the desired height
                                child: LinearProgressIndicator(
                                  value: bicep_repetitions_count / repetitionsProvider.selectedRepetitions,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5),
                            // Display count below the progress bar
                            Text(
                              'Bicep Count: $bicep_repetitions_count',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            GestureDetector(
                              child: Container(
                                width: 250, // Set the desired width
                                height: 10, // Set the desired height
                                child: LinearProgressIndicator(
                                  value: shoulder_repetitions_count / repetitionsProvider.selectedRepetitions,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5),
                            // Display count below the progress bar
                            Text(
                              'shoulder Count: $shoulder_repetitions_count',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            GestureDetector(
                              child: Container(
                                width: 250, // Set the desired width
                                height: 10, // Set the desired height
                                child: LinearProgressIndicator(
                                  value: tricep_repetitions_count / repetitionsProvider.selectedRepetitions,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5),
                            // Display count below the progress bar
                            Text(
                              'tricep Count: $tricep_repetitions_count',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                          ] else ... [
                            Text(
                              'Bicep Count: $bicep_repetitions_count',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            Text(
                              'shoulder Count: $shoulder_repetitions_count',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            Text(
                              'tricep Count: $tricep_repetitions_count',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                          ]
                        ],
                      );
                    },
                  ),

                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        if (stopwatch.isRunning) {
                          stopwatch.stop();
                        } else {
                          stopwatch.start();
                        }
                      });
                    },
                    padding: EdgeInsets.all(0),
                    child: Container(
                      height: 250,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xff0395eb),
                          width: 4,
                        ),
                      ),
                      child: Text(
                        returnFormattedText(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        stopwatch.reset();
                      });
                    },
                    padding: EdgeInsets.all(0),
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      elapsedTime = getElapsedTime();
                      await endSession(context);
                    },
                    child: Text("End Workout Session"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void addSession(BuildContext context, Map<String, double> reps, String duration, double calories) async {
  final storage = ActivityStorage();
  List<Session> sessions = await storage.loadActivities();
  sessions.add(Session(reps: reps, duration: duration, calories: calories));
  logger.d(reps);
  logger.d(duration);
  logger.d(calories);
  await storage.saveActivities(sessions);
  final progressPageState = context.findAncestorStateOfType<ProgressPageState>();
  progressPageState?.loadActivities();
}

Future<double> calculateCaloriesBurned(BuildContext context) async {
  // Retrieve profile data from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String name = prefs.getString('name') ?? '';
  int age = prefs.getInt('age') ?? 0;
  double height = prefs.getDouble('height') ?? 0.0;
  double weight = prefs.getDouble('weight') ?? 0.0;
  String gender = prefs.getString('gender') ?? '';

  // Use the retrieved data to calculate calories burned
  double caloriesBurned = _calculateCalories(age, height, weight, gender, elapsedTime, shoulder_repetitions_count, bicep_repetitions_count, tricep_repetitions_count);
  return caloriesBurned;
}

double _calculateCalories(int age, double height, double weight, String gender, String elapsedTime, double sr, double br, double tr) {
  // Convert elapsed time to hours
  double timeInHours = _convertElapsedTimeToHours(elapsedTime);

  double bmr;
  if (gender == 'male') {
    bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
  } else {
    bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
  }

  double metValue = 0;
  double timeInMinutes = timeInHours * 60;

  if (br + sr + tr < 3) {
    metValue = 0; // Handle low activity levels appropriately
  } else {
    metValue = 0.75 + (timeInMinutes / 10.0) + ((br + sr + tr) / 100.0);
  }  

  double caloriesBurned = bmr * metValue * timeInHours;
  return caloriesBurned.roundToDouble();
}

double _convertElapsedTimeToHours(String elapsedTime) {
  List<String> parts = elapsedTime.split(':');
  if (parts.length != 3) {
    throw ArgumentError('time format wrong');
  }

  int minutes = int.parse(parts[0]);
  int seconds = int.parse(parts[1]);
  int milliseconds = int.parse(parts[2]);

  double totalHours = minutes / 60 + seconds / 3600 + milliseconds / 3600000;
  return totalHours;
}
