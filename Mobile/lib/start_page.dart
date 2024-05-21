//global variable code

// import 'package:flutter/material.dart';
// import 'package:smart_dumbbell_mobile/main.dart'; 
// import 'package:smart_dumbbell_mobile/working_page.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:logger/logger.dart' as myLogger;
// import 'package:smart_dumbbell_mobile/global.dart';
// //int repetitions = 0;

// void updateRepetitions(int newReps) {
//   repetitions_count = newReps;
// }

// void resetRepetitions() {
//   repetitions_count = 0;
// }

// class StartPage extends StatefulWidget {
//   @override
//   _StartPageState createState() => _StartPageState();
// }

// class _StartPageState extends State<StartPage> {
//   final _ble = FlutterReactiveBle();
//   StreamSubscription<DiscoveredDevice>? _scanSub;
//   StreamSubscription<ConnectionStateUpdate>? _connectSub;
//   StreamSubscription<List<int>>? _notifySub;
//   var _found = false;
//   var _isLoading = false;
//   final logger = myLogger.Logger();

//   @override
//   void dispose() {
//     _notifySub?.cancel();
//     _connectSub?.cancel();
//     _scanSub?.cancel();
//     super.dispose();
//   }

//   void _onScanUpdate(DiscoveredDevice d) {
//     if (d.name == 'BLE-TEMP' && !_found) {
//       logger.d('Scan done!');
//       _found = true;
//       _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
//         if (update.connectionState == DeviceConnectionState.connected) {
//           setState(() {
//             isBluetoothConnected.value = true;
//             _isLoading = false;
//           });
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => WorkingPage()),
//           );
//           _onConnected(d.id);
//         } else if (update.connectionState == DeviceConnectionState.disconnected) {
//           setState(() {
//             isBluetoothConnected.value = false;
//             _isLoading = false;
//           });
//         }
//       });
//     }
//   }

//   void _onConnected(String deviceId) {
//     logger.d('On Connect!');
//     final characteristic = QualifiedCharacteristic(
//       deviceId: deviceId,
//       serviceId: Uuid.parse('00000000-5EC4-4083-81CD-A10B8D5CF6EC'),
//       characteristicId: Uuid.parse('00000001-5EC4-4083-81CD-A10B8D5CF6EC'),
//     );

//     _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) {
//       setState(() {
//         value = const Utf8Decoder().convert(bytes);
//         logger.d(value);
//         _parseAndSaveRepetitions(value);
//       });
//     });
//   }

//   void _parseAndSaveRepetitions(String data) {    // parse string and save int
//     final regex = RegExp(r'\d+');
//     final match = regex.firstMatch(data);
//     if (match != null) {
//       final repetitions_count = int.parse(match.group(0)!);
//       updateRepetitions(repetitions_count);
//     }
//   }

//   void _startBluetoothScan() {
//     _scanSub?.cancel();
//     _found = false;
//     setState(() {
//       _isLoading = true;
//     });
//     _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Smart Dumbbell'),
//       ),
//       body: Stack(
//         children: <Widget>[
//           // Start button
//           Align(
//             alignment: Alignment.center,
//             child: ElevatedButton(
//               onPressed: () {
//                 resetRepetitions(); // Reset repetitions when starting a new workout
//                 _startBluetoothScan();
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: CircleBorder(),
//                 padding: EdgeInsets.all(120), // Adjust the size of the button
//               ),
//               child: Text('START', style: TextStyle(fontSize: 50)), // Adjust the size of the font
//             ),
//           ),
//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: Colors.white,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }




//old code

// import 'package:flutter/material.dart';
// import 'package:smart_dumbbell_mobile/main.dart';
// import 'package:smart_dumbbell_mobile/working_page.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:logger/logger.dart' as myLogger;

// int repetitions = 0;

// void updateRepetitions(int newReps) {
//   repetitions = newReps;
// }

// void resetRepetitions() {
//   repetitions = 0;
// }

// class StartPage extends StatefulWidget {
//   @override
//   _StartPageState createState() => _StartPageState();
// }

// class _StartPageState extends State<StartPage> {
//   final _ble = FlutterReactiveBle();
//   StreamSubscription<DiscoveredDevice>? _scanSub;
//   StreamSubscription<ConnectionStateUpdate>? _connectSub;
//   StreamSubscription<List<int>>? _notifySub;
//   var _found = false;
//   var _isLoading = false;
//   final logger = myLogger.Logger();
//   int _progress = 0; // Progress variable

//   @override
//   void dispose() {
//     _notifySub?.cancel();
//     _connectSub?.cancel();
//     _scanSub?.cancel();
//     super.dispose();
//   }

//   void _onScanUpdate(DiscoveredDevice d) {
//     if (d.name == 'BLE-TEMP' && !_found) {
//       logger.d('Scan done!');
//       _found = true;
//       _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
//         if (update.connectionState == DeviceConnectionState.connected) {
//           setState(() {
//             isBluetoothConnected.value = true;
//             _isLoading = false;
//           });
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => WorkingPage()),
//           );
//           _onConnected(d.id);
//         } else if (update.connectionState == DeviceConnectionState.disconnected) {
//           setState(() {
//             isBluetoothConnected.value = false;
//             _isLoading = false;
//           });
//         }
//       });
//     }
//   }

//   void _onConnected(String deviceId) {
//     logger.d('On Connect!');
//     final characteristic = QualifiedCharacteristic(
//       deviceId: deviceId,
//       serviceId: Uuid.parse('00000000-5EC4-4083-81CD-A10B8D5CF6EC'),
//       characteristicId: Uuid.parse('00000001-5EC4-4083-81CD-A10B8D5CF6EC'),
//     );

//     _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) {
//       setState(() {
//         value = const Utf8Decoder().convert(bytes);
//         logger.d(value);
//         _parseAndSaveRepetitions(value);
//       });
//     });
//   }

//   void _parseAndSaveRepetitions(String data) {    // parse string and save int
//     final regex = RegExp(r'\d+');
//     final match = regex.firstMatch(data);
//     if (match != null) {
//       final repetitions = int.parse(match.group(0)!);
//       updateRepetitions(repetitions);
//     }
//   }

//   void _startBluetoothScan() {
//     _scanSub?.cancel();
//     _found = false;
//     setState(() {
//       _isLoading = true;
//     });
//     _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
//   }

//   void _incrementProgress() {
//     setState(() {
//       if (_progress < 30) {
//         _progress++;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Smart Dumbbell'),
//       ),
//       body: Stack(
//         children: <Widget>[
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Clickable progress bar
//               GestureDetector(
//                 onTap: _incrementProgress,
//                 child: Container(
//                   width: 200, // Set the desired width
//                   height: 10, // Set the desired height
//                   child: LinearProgressIndicator(
//                     value: _progress / 30,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//               // Display count below the progress bar
//               Text(
//                 'Count: $_progress',
//                 style: TextStyle(fontSize: 24),
//               ),
//               // Start button
//               Align(
//                 alignment: Alignment.center,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     resetRepetitions(); // Reset repetitions when starting a new workout
//                     _startBluetoothScan();
//                     _incrementProgress(); // Increment progress when button is pressed
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: CircleBorder(),
//                     padding: EdgeInsets.all(50), // Adjust the size of the button
//                   ),
//                   child: Text('START', style: TextStyle(fontSize: 30)), // Adjust the size of the font
//                 ),
//               ),
//             ],
//           ),
//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: Colors.white,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }



//json code
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as myLogger;
import 'package:path_provider/path_provider.dart';
import 'package:smart_dumbbell_mobile/global.dart';
import 'package:smart_dumbbell_mobile/main.dart'; 
import 'package:smart_dumbbell_mobile/working_page.dart';

// int bicep_repetitions_count = 0;
// int shoulder_repetitions_count = 0;

Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/repetitions.json');
}

Future<File> writeRepetitions() async {
  final file = await _localFile;
  return file.writeAsString(jsonEncode({
    'bicep_repetitions': bicep_repetitions_count,
    'shoulder_repetitions': shoulder_repetitions_count,
  }));
}

void updateRepetitions(String type, int newReps) async {
  if (type == 'Bicep') {
    bicep_repetitions_count = newReps;
  } else if (type == 'Shoulder') {
    shoulder_repetitions_count = newReps;
  }
  await writeRepetitions();
}

void resetRepetitions() async {
  bicep_repetitions_count = 0;
  shoulder_repetitions_count = 0;
  await writeRepetitions();
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  StreamSubscription<List<int>>? _notifySub;
  var _found = false;
  var _isLoading = false;
  final logger = myLogger.Logger();

  @override
  void dispose() {
    _notifySub?.cancel();
    _connectSub?.cancel();
    _scanSub?.cancel();
    super.dispose();
  }

  void _onScanUpdate(DiscoveredDevice d) {
    if (d.name == 'BLE-TEMP' && !_found) {
      logger.d('Scan done!');
      _found = true;
      _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          setState(() {
            isBluetoothConnected.value = true;
            _isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkingPage()),
          );
          _onConnected(d.id);
        } else if (update.connectionState == DeviceConnectionState.disconnected) {
          setState(() {
            isBluetoothConnected.value = false;
            _isLoading = false;
          });
        }
      });
    }
  }

  void _onConnected(String deviceId) {
    logger.d('On Connect!');
    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse('00000000-5EC4-4083-81CD-A10B8D5CF6EC'),
      characteristicId: Uuid.parse('00000001-5EC4-4083-81CD-A10B8D5CF6EC'),
    );

    _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) {
      setState(() {
        value = const Utf8Decoder().convert(bytes);
        logger.d(value);
        _parseAndSaveRepetitions(value);
      });
    });
  }

  void _parseAndSaveRepetitions(String data) {    // parse string and save int
    final regex = RegExp(r'(Bicep|Shoulder) (\d+)');
    final match = regex.firstMatch(data);
    if (match != null) {
      final type = match.group(1)!;
      final repetitions_count = int.parse(match.group(2)!);
      updateRepetitions(type, repetitions_count);
    }
  }

  void _startBluetoothScan() {
    _scanSub?.cancel();
    _found = false;
    setState(() {
      _isLoading = true;
    });
    _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Dumbbell'),
      ),
      body: Stack(
        children: <Widget>[
          // Start button
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                resetRepetitions(); // Reset repetitions when starting a new workout
                _startBluetoothScan();
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(120), // Adjust the size of the button
              ),
              child: Text('START', style: TextStyle(fontSize: 50)), // Adjust the size of the font
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
