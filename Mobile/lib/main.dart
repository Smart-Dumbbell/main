import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_dumbbell_mobile/start_page.dart';
import 'package:smart_dumbbell_mobile/me_page.dart';
import 'package:smart_dumbbell_mobile/goal_page.dart';
import 'package:smart_dumbbell_mobile/progress_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_dumbbell_mobile/global.dart';



ValueNotifier<bool> isBluetoothConnected = ValueNotifier(false);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRepetitions = await _loadInitialRepetitions();
  runApp(
    ChangeNotifierProvider(
      create: (context) => RepetitionsProvider(initialRepetitions),
      child: MyApp(),
    ),
  );
}

Future<int> _loadInitialRepetitions() async {
  final prefs = await SharedPreferences.getInstance();
  final selectedBox = prefs.getInt('selectedBox') ?? 3;
  return _getSelectedRepetitions(selectedBox);
}

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
        '/me': (context) => MePage(),
        '/progress': (context) => ProgressPage(),
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
    GoalPage(onGoalSelected: (int selectedIndex) {}),
  ];

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

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
        automaticallyImplyLeading: false,
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
        onTap: (index) {
          _onItemTapped(index);
          if (index == 2) { // If ProgressPage is selected
            loadActivities(context);
          }
        },
      ),
    );
  }

  void loadActivities(BuildContext context) {
    final progressPageState = context.findAncestorStateOfType<ProgressPageState>();
    progressPageState?.loadActivities();
  }

    Future<void> requestLocationPermission() async {
     final status1 = await Permission.bluetoothScan.request();
     final status2 = await Permission.bluetoothAdvertise.request();
     final status3 = await Permission.bluetoothConnect.request();

    if (status1.isGranted & status2.isGranted & status3.isGranted){
      print('Location permission granted');
    }
    else if (status1.isDenied & status2.isDenied & status3.isDenied){
      print('Location permission denied');
    }
    else if (status1.isPermanentlyDenied & status2.isPermanentlyDenied & status3.isPermanentlyDenied){
      openAppSettings();
    }

  }

}
