import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GoalPage extends StatefulWidget {
  final Function(int) onGoalSelected;
  const GoalPage({required this.onGoalSelected});
  @override
  _GoalPageState createState() => _GoalPageState();
}


class _GoalPageState extends State<GoalPage> {
  late SharedPreferences _prefs;
  int _selectedBox = -1; // Initially no box is selected

  @override
  void initState() {
    super.initState();
    _loadSelectedBox();
  }

  // Load the selected box index from SharedPreferences
  Future<void> _loadSelectedBox() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBox = _prefs.getInt('selectedBox') ?? -1;
    });
  }

  Future<void> _saveSelectedBox(int index) async {
    setState(() {
      _selectedBox = index;
    });
    await _prefs.setInt('selectedBox', index);
    widget.onGoalSelected(index);

    // Update RepetitionsProvider with the selected repetitions
    Provider.of<RepetitionsProvider>(context, listen: false).setSelectedRepetitions(_getSelectedRepetitions(index));
  }

  // Helper function to get selected repetitions based on the box index
  int _getSelectedRepetitions(int index) {
    switch (index) {
      case 0:
        return 20;
      case 1:
        return 30;
      case 2:
        return 40;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PressableBox(
              text: 'Beginner: 20 repetitions',
              isSelected: _selectedBox == 0,
              onTap: () {
                _saveSelectedBox(0);
                widget.onGoalSelected(0);
              },
            ),
            SizedBox(height: 20),
            PressableBox(
              text: 'Intermediate: 30 repetitions',
              isSelected: _selectedBox == 1,
              onTap: () {
                _saveSelectedBox(1);
                widget.onGoalSelected(1);
              },
            ),
            SizedBox(height: 20),
            PressableBox(
              text: 'Advanced: 40 repetitions',
              isSelected: _selectedBox == 2,
              onTap: () {
                _saveSelectedBox(2);
                widget.onGoalSelected(2);
              },
            ),
            SizedBox(height: 4),
            PressableBox(
              text: 'Reset',
              isSelected: _selectedBox == 3,
              onTap: () {
                _saveSelectedBox(-1);
                widget.onGoalSelected(-1);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PressableBox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const PressableBox({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class RepetitionsProvider extends ChangeNotifier {
  int _selectedRepetitions = 0;

  int get selectedRepetitions => _selectedRepetitions;

  void setSelectedRepetitions(int repetitions) {
    _selectedRepetitions = repetitions;
    notifyListeners();
  }
}