import 'package:flutter/material.dart';
import 'package:smart_dumbbell_mobile/main.dart';
import 'package:smart_dumbbell_mobile/working_page.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as MyLogger;

class StartPage extends StatelessWidget {
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
          // Bluetooth button
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
                      MaterialPageRoute(builder: (context) => BluetoothPage(title: 'Demo')),
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



// class BluetoothPage extends StatefulWidget {
//   @override
//   _BluetoothPageState createState() => _BluetoothPageState();
// }

// class _BluetoothPageState extends State<BluetoothPage> {
//   //bool isBluetoothConnected = false; // Step 4: Bluetooth connection state

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Page'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 isBluetoothConnected.value = true; // Update the ValueNotifier
//                 Navigator.pop(context); // Go back to the home page
//               },
//               child: Text('Connect'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 isBluetoothConnected.value = false; // Update the ValueNotifier
//                 Navigator.pop(context); // Go back to the home page
//               },
//               child: Text('Disconnect'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key, required this.title});

  final String title;

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  StreamSubscription<List<int>>? _notifySub;

  var _found = false;
  var _value = '';
  

  @override
  initState() {
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

  final logger = MyLogger.Logger();

  void _onScanUpdate(DiscoveredDevice d) {
    // logger.d('On Scan!');
    if (d.name == 'BLE-TEMP' && !_found) {
      logger.d('Scan done!');
      _found = true;
      _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          _onConnected(d.id);
        }
      });
    }
  }

  void _onConnected(String deviceId) {
    logger.d('On Connect!');
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: _value.isEmpty
              ? const CircularProgressIndicator()
              : Text(_value, style: Theme.of(context).textTheme.titleLarge)),
    );
  }
}