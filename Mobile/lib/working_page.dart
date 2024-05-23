import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_dumbbell_mobile/goal_page.dart';
import 'package:smart_dumbbell_mobile/report_page.dart';
import 'package:smart_dumbbell_mobile/start_page.dart';

String elapsedTime = "";

class WorkingPage extends StatefulWidget {
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
                                  value: repetitions / repetitionsProvider.selectedRepetitions,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5),
                            // Display count below the progress bar
                            Text(
                              'Bicep Count: $repetitions',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            GestureDetector(
                              child: Container(
                                width: 250, // Set the desired width
                                height: 10, // Set the desired height
                                child: LinearProgressIndicator(
                                  value: shoulder / repetitionsProvider.selectedRepetitions,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5),
                            // Display count below the progress bar
                            Text(
                              'shoulder Count: $repetitions',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            GestureDetector(
                              child: Container(
                                width: 250, // Set the desired width
                                height: 10, // Set the desired height
                                child: LinearProgressIndicator(
                                  value: tricep / repetitionsProvider.selectedRepetitions,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5),
                            // Display count below the progress bar
                            Text(
                              'tricep Count: $repetitions',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                          ] else ... [
                            Text(
                              'Bicep Count: $repetitions',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            Text(
                              'shoulder Count: $shoulder',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                            Text(
                              'tricep Count: $tricep',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 2.5),
                          ]
                        ],
                      );
                    },
                  ),

                  // SizedBox(height: 10),
                  // // Display count below the progress bar
                  // Text(
                  //   'Count: $repetitions',
                  //   style: TextStyle(fontSize: 18),
                  // ),
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
                    onPressed: () {
                      elapsedTime = getElapsedTime();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportPage()),
                      );
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
