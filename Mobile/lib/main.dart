//import 'dart:html';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
 
import 'package:flutter/cupertino.dart';
//import 'package:smart_dumbbell_mobile/bar_graphs/bar_graph.dart';
import 'package:provider/provider.dart';
// import 'package:smart_dumbbell_mobile/start_page.dart';
import 'package:smart_dumbbell_mobile/working_page.dart';
import 'package:smart_dumbbell_mobile/me_page.dart';
import 'package:smart_dumbbell_mobile/goal_page.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as MyLogger;


ValueNotifier<bool> isBluetoothConnected = ValueNotifier(false);

var _value = '';


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
        // '/start': (context) => StartPage(),
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
  final _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  StreamSubscription<List<int>>? _notifySub;
  var _found = false;

  @override
  void initState() {
    super.initState();
    _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
  }

  @override
  void dispose() {
    _notifySub?.cancel();
    _connectSub?.cancel();
    _scanSub?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < 4) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onScanUpdate(DiscoveredDevice d) {
    if (d.name == 'BLE-TEMP' && !_found) {
      _found = true;
      _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          setState(() {
            isBluetoothConnected.value  = true;
          });
          _onConnected(d.id);
        }
        else {
          isBluetoothConnected.value = false;
        }
      });
    }
  }

  void _onConnected(String deviceId) {
    final characteristic = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: Uuid.parse('00000000-5EC4-4083-81CD-A10B8D5CF6EC'),
        characteristicId: Uuid.parse('00000001-5EC4-4083-81CD-A10B8D5CF6EC'));

    _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) {
      setState(() {
        _value = const Utf8Decoder().convert(bytes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Home Page'),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Center(
        child: _selectedIndex == 0
            ? ElevatedButton(
                onPressed: () {
                  // Your code here for Start button
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
              )
            : _value.isEmpty
                ? const CircularProgressIndicator()
                : Text(_value, style: Theme.of(context).textTheme.titleLarge),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20, right: 20),
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
                _scanSub?.cancel();
                _found = false;
                setState(() {});
                _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
              },
            );
          },
        ),
      ),
    );
  }
}



// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;

//   static List<Widget> _widgetOptions = <Widget>[
//     StartPage(),
//     MePage(),
//     ProgressPage(),
//     //GoalPage(),
//     GoalPage(onGoalSelected: (int selectedIndex) {}),
//   ];

//   void _onItemTapped(int index) {

//     if (index >= 0 && index < _widgetOptions.length) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
        
//         //title: Text('Home Page'),
//         automaticallyImplyLeading: false, // Remove the back arrow
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: 'Me',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.report),
//             label: 'Progress',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.fitness_center),
//             label: 'Goal',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.black,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

