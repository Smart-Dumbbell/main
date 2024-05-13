//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
 
import 'package:flutter/cupertino.dart';
import 'package:smart_dumbbell_mobile/bar_graphs/bar_graph.dart';
import 'package:provider/provider.dart';

ValueNotifier<bool> isBluetoothConnected = ValueNotifier(false);


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RepetitionsProvider(),
      child: MyApp(),
    ),
  );
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/start': (context) => StartPage(),
        '/me': (context) => MePage(),
        '/progress': (context) => ProgressPage(),
        //'/goal': (context) => GoalPage(onGoalSelected: (int ) {  },),
        '/goal': (context) => GoalPage(onGoalSelected: (int selectedIndex) {}),

      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    StartPage(),
    MePage(),
    ProgressPage(),
    //GoalPage(),
    GoalPage(onGoalSelected: (int selectedIndex) {}),
  ];

  void _onItemTapped(int index) {

    if (index >= 0 && index < _widgetOptions.length) {
    setState(() {
      _selectedIndex = index;
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        //title: Text('Home Page'),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Goal',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Dumbbell'),
      ),
      body: Stack(
        children: <Widget>[
          //start button
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                // Your code here
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkingPage()),
                );
              },
              style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(120), // Adjust the size of the button
            ),
            child: Text('START', style: TextStyle(fontSize: 50)), // Adjust the size of the font
            ),
          ),
          //bluetooth button
          Positioned(
            top: 20,
            right: 20,
            child: ValueListenableBuilder<bool>(
              valueListenable: isBluetoothConnected,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(
                    Icons.bluetooth,
                    color: value ? Colors.blue : Colors.red,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BluetoothPage()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


//bluetooth page
class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  //bool isBluetoothConnected = false; // Step 4: Bluetooth connection state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                isBluetoothConnected.value = true; // Update the ValueNotifier
                Navigator.pop(context); // Go back to the home page
              },
              child: Text('Connect'),
            ),
            ElevatedButton(
              onPressed: () {
                isBluetoothConnected.value = false; // Update the ValueNotifier
                Navigator.pop(context); // Go back to the home page
              },
              child: Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}


class MePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController gender = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _ageController.text = prefs.getInt('age')?.toString() ?? '';
      _heightController.text = prefs.getDouble('height')?.toString() ?? '';
      _weightController.text = prefs.getDouble('weight')?.toString() ?? '';
      gender.text = prefs.getString('gender') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: gender,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Height'),
            ),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Weight'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveData();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('gender', gender.text);
    await prefs.setInt('age', int.tryParse(_ageController.text) ?? 0);
    await prefs.setDouble('height', double.tryParse(_heightController.text) ?? 0);
    await prefs.setDouble('weight', double.tryParse(_weightController.text) ?? 0);

    // Optionally, you can show a message that data has been saved
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved successfully')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    gender.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

class ProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Page'),
      ),
      body: Center(
        child: Text('This is the Progress Page'),
      ),
    );
  }
}

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
          child: Column( // this is the column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
 
              CupertinoButton(
                onPressed: () {
                  handleStartStop();
                },
                padding: EdgeInsets.all(0),
                child: Container(
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,  // this one is use for make the circle on ui.
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
 
              SizedBox(height: 15,),
 
              CupertinoButton(     // this the cupertino button and here we perform all the reset button function
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
        ),
      ),
    ); 
  }
}

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

  // Save the selected box index to SharedPreferences
  Future<void> _saveSelectedBox(int index) async {
    setState(() {
      _selectedBox = index;
    });
    await _prefs.setInt('selectedBox', index);
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