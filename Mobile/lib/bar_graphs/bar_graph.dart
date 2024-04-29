import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_dumbbell_mobile/bar_graphs/bar_graph_report_data.dart';

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
    
  Widget getTopTitles(double value, TitleMeta meta) {
  final int index = value.toInt() -1 ;
  final double repValue = repcount[index];

  const style = TextStyle(
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 0, 0, 0),
    fontSize: 10,
  );

  return SideTitleWidget(child: Text('$repValue', style: style), axisSide: meta.axisSide);
}

    
    return BarChart(
      BarChartData(
        maxY: 50,
        minY: 0,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: getTopTitles)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              getTitlesWidget: getBottomTitles,
              ),
            ),
          ),
        
        barGroups: myBarData.barData
          .map(
            (data)=> BarChartGroupData(
              x: data.x.toInt(), 
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

Widget getBottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 0, 0, 0),
    fontSize: 10,
  );

  Widget text;
  switch (value.toInt()) {
    case 1:
      text = const Text('Incomplete', style: style);
      break;
    case 2:
      text = const Text('Complete', style: style);
      break;
    case 3:
      text = const Text('Total', style: style);
      break;
    default:
      text = const Text('', style: style);
  }
  
  return SideTitleWidget(child: text, axisSide: meta.axisSide);
}

