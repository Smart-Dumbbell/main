import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_dumbbell_mobile/main.dart';
import 'package:smart_dumbbell_mobile/bar_graphs/bar_graph.dart';
import 'package:smart_dumbbell_mobile/working_page.dart';
import 'package:smart_dumbbell_mobile/global.dart';


class ReportPage extends StatelessWidget {
  List<double> repcount = [shoulder_repetitions_count, bicep_repetitions_count , tricep_repetitions_count]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rep Counter'),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: MyBarGraph(
                repcount: repcount,
              ),
            ),
            SizedBox(height: 20),

            // Use FutureBuilder to asynchronously call calculateCaloriesBurned and display the result
            FutureBuilder<double>(
              future: calculateCaloriesBurned(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a loading indicator while the calculation is in progress
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Display an error message if the calculation fails
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Display the calculated calories burned
                  return Text('Calories burned: ${snapshot.data?.toStringAsFixed(0)}');
                }
              },
            ),
            Row(
  
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Time: '),
                // dummy time
                Text(elapsedTime),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              child: Text('Return to Home Page'),
            ),
            ],
        ),
      ),
    );
  }

  // Function to asynchronously calculate calories burned using profile data
  Future<double> calculateCaloriesBurned(BuildContext context) async {
    // Retrieve profile data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? '';
    int age = prefs.getInt('age') ?? 0;
    double height = prefs.getDouble('height') ?? 0.0;
    double weight = prefs.getDouble('weight') ?? 0.0;
    String gender = prefs.getString('gender') ?? '';

    // Use the retrieved data to calculate calories burned
    caloriesBurned = _calculateCalories(age, height, weight, gender, elapsedTime, shoulder_repetitions_count, bicep_repetitions_count, tricep_repetitions_count);
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

    if (br + sr + tr < 3){
      ///
    } 
    else {
      metValue = 0.75 + (timeInMinutes/ 10.0) + ((br + sr + tr) / 100.0);
    }  
    
    double caloriesBurned = bmr * metValue * timeInHours;
    caloriesBurned = caloriesBurned.roundToDouble();
    return caloriesBurned;
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
}