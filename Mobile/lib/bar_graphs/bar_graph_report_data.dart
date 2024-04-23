import 'package:smart_dumbbell_mobile/bar%20graphs/individualbar.dart';

class BarGraphData{
  double goodrep;
  double badrep;
  double totalrep;

  BarGraphData({
    required this.goodrep,
    required this.badrep,
    required this.totalrep
  });

  List<individualBar> barData = [];

  void initializebardata() {
    barData = [
      individualBar(x: 1, y: badrep),
      individualBar(x: 2, y: goodrep),
      individualBar(x: 3, y: totalrep)
    ];
  }
}