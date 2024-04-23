import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_dumbbell_mobile/bar%20graphs/bar_graph_report_data.dart';

class MyBarGraph extends StatelessWidget {
  final List repcount;
  const MyBarGraph({
    super.key,
    required this.repcount,
    });

  @override
  Widget build(BuildContext context) {
    BarGraphData myBarData = BarGraphData(
      goodrep: repcount[1], 
      badrep: repcount[0], 
      totalrep: repcount[2]);

      myBarData.initializebardata();
    
    
    return BarChart(
      BarChartData(
        maxY: 50,
        minY: 0,
        barGroups: myBarData.barData
          .map(
            (data)=> BarChartGroupData(
              x: data.x, 
              barRods: [
                BarChartRodData(toY: data.y),
              ],
            ),
          )
          .toList(),
      ),
    );
  }
}