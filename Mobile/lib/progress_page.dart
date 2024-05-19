import 'dart:math';

import 'package:flutter/material.dart';


// class ProgressPage extends StatelessWidget {
//   final List<Map<String, String>> activities;

//   const ProgressPage({Key? key, this.activities = const []}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Recent Activity', style: Theme.of(context).textTheme.headlineMedium),
//           const SizedBox(height: 20),
//           Expanded(
//             child: ListView.builder(
//               itemCount: activities.length,
//               itemBuilder: (context, index) {
//                 final activity = activities[index];
//                 return ActivityItem(
//                   activity: activity['activity']!,
//                   duration: activity['duration']!,
//                   calories: activity['calories']!,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Dummey data
    final activities = [
      {'activity': 'Bicep curl', 'duration': '30min', 'calories': '55kcal'},
      {'activity': 'Shoulder Press', 'duration': '45min', 'calories': '75kcal'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Progress Page')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) => ActivityItem(
                  activity: activities[index]['activity']!,
                  duration: activities[index]['duration']!,
                  calories: activities[index]['calories']!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class ActivityItem extends StatelessWidget {
  final String activity;
  final String duration;
  final String calories;

  const ActivityItem({
    Key? key,
    required this.activity,
    required this.duration,
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
          border: Border.all(
            color: const Color(0xffe1e1e1),
          ),
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
                    )),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              activity,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Expanded(child: SizedBox()),
            const Icon(Icons.timer, size: 12),
            const SizedBox(width: 5),
            Text(
              duration,
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

