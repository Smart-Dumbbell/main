import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_dumbbell_mobile/main.dart';
import 'package:smart_dumbbell_mobile/bar_graphs/bar_graph.dart';



class ReportPage extends StatelessWidget {
  List<double> repcount = [10, 25, 35]; // dummy data

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
              future: _calculateCaloriesBurned(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a loading indicator while the calculation is in progress
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Display an error message if the calculation fails
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Display the calculated calories burned
                  return Text('Calories burned: ${snapshot.data}');
                }
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              // children: [
              //   Text('Calories burned: '),
              //   // Replace '0' with the actual calculated calories burned
              //   //For men: BMR = (10 * weight in kg) + (6.25 * height in cm) - (5 * age in years) + 5
              //   //For women: BMR = (10 * weight in kg) + (6.25 * height in cm) - (5 * age in years) - 161
              //   //MET for 10lb = 2 20 = 2.2 30 = 2.4 
              //   //cal burned = (BMR * MET * duration(in hours)) / 10
              //   Text('1'),
              // ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Time: '),
                // dummy time
                Text('0:00'),
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
  Future<double> _calculateCaloriesBurned(BuildContext context) async {
    // Retrieve profile data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? '';
    int age = prefs.getInt('age') ?? 0;
    double height = prefs.getDouble('height') ?? 0.0;
    double weight = prefs.getDouble('weight') ?? 0.0;
    String gender = prefs.getString('gender') ?? '';

    // Use the retrieved data to calculate calories burned
    double caloriesBurned = _calculateCalories(age, height, weight, gender);
    return caloriesBurned;
  }

  double _calculateCalories(int age, double height, double weight, String gender) {
    //bmr x met x time in hours
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    //////random met until time functionality is working
    List<double> METLIST = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5];
    Random random = Random();
    int randomIndex = random.nextInt(METLIST.length);
    double randomMET = METLIST[randomIndex];

    double dummytime = 2 / 60;  //dummy time
    double caloriesBurned = bmr * randomMET * dummytime;
    return caloriesBurned;
  }
}