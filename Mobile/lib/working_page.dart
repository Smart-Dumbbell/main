import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_dumbbell_mobile/goal_page.dart';
import 'package:smart_dumbbell_mobile/report_page.dart';
import 'package:smart_dumbbell_mobile/global.dart';


class WorkingPage extends StatefulWidget {
  @override
  _WorkingPageState createState() => _WorkingPageState();
}

class _WorkingPageState extends State<WorkingPage> {
  late Stopwatch stopwatch;
  late Timer t;
 
  void handleStartStop() {
    if(stopwatch.isRunning) {
      stopwatch.stop();
    }
    else {
      stopwatch.start();
    }
  }
 
  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;
 
    String milliseconds = (milli % 1000).toString().padLeft(3, "0"); // this one for the miliseconds
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0"); // this is for the second
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0"); // this is for the minute
 
    return "$minutes:$seconds:$milliseconds";
  }
 
  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
 
    t = Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    t.cancel(); // Cancel the timer in dispose()
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center, // Adjust as needed
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Consumer<RepetitionsProvider>(
                  //   builder: (context, repetitionsProvider, child) {
                  //     return Text(
                  //       'Goal Repetitions: ${repetitionsProvider.selectedRepetitions}',
                  //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //     );
                  //   },
                  // ),
                  // GestureDetector(
                  //   child: Container(
                  //     width: 200, // Set the desired width
                  //     height: 10, // Set the desired height
                  //     child: LinearProgressIndicator(
                  //       value: repetitions_count / repetitionsProvider.selectedRepetitions,
                  //     ),
                  //   ),
                  // ),
                  Consumer<RepetitionsProvider>(
                    builder: (context, repetitionsProvider, child) {
                      return Column(
                        children: [
                          Text(
                            'Goal Repetitions: ${repetitionsProvider.selectedRepetitions}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            child: Container(
                              width: 200, // Set the desired width
                              height: 10, // Set the desired height
                              child: LinearProgressIndicator(
                                value: shoulder_repetitions_count / repetitionsProvider.selectedRepetitions,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  // Display count below the progress bar
                  Text(
                    'Count: $repetitions_count',
                    style: TextStyle(fontSize: 24),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      handleStartStop();
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
                      child: Text(returnFormattedText(), style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ),
                  SizedBox(height:15),
                  CupertinoButton(
                    onPressed: () {
                      stopwatch.reset();
                    },
                    padding: EdgeInsets.all(0),
                    child: Text("Reset", style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportPage()),
                      );
                    },
                    child: Text("End Workout Section"),
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

