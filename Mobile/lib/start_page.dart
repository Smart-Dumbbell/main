import 'package:flutter/material.dart';
import 'package:smart_dumbbell_mobile/main.dart'; 
import 'package:smart_dumbbell_mobile/working_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as myLogger;

double repetitions = 0;
double shoulder = 0;
double tricep = 0;

void updateRepetitions(double newReps, String type) {
  switch (type) {
    case 'Bicep':
      repetitions = newReps;
      break;
    case 'Shoulder':
      shoulder = newReps;
      break;
    case 'Tricep':
      tricep = newReps;
      break;
    default:
      break;
  }
}

void resetRepetitions() {
  repetitions = 0;
  shoulder = 0;
  tricep = 0;
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

  void _parseAndSaveRepetitions(String data) {
    final regex = RegExp(r'(\w+) (\d+)');
    final match = regex.firstMatch(data);

    if (match != null) {
      final type = match.group(1)!;
      final repetitions = double.parse(match.group(2)!);
      updateRepetitions(repetitions, type);
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
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                resetRepetitions();
                _startBluetoothScan();
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(120),
              ),
              child: Text('START', style: TextStyle(fontSize: 50)),
            ),
          ),
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