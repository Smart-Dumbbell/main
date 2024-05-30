import 'package:flutter/material.dart';
import 'package:smart_dumbbell_mobile/main.dart'; 
import 'package:smart_dumbbell_mobile/working_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:logger/logger.dart' as myLogger;
import 'package:smart_dumbbell_mobile/global.dart';

void updateRepetitions(double newReps, String type) {
  switch (type) {
    case 'Bicep':
      bicep_repetitions_count = newReps;
      break;
    case 'Shoulder':
      shoulder_repetitions_count = newReps;
      break;
    case 'Tricep':
      tricep_repetitions_count = newReps;
      break;
    default:
      break;
  }
}

void resetRepetitions() {
  bicep_repetitions_count = 0;
  shoulder_repetitions_count = 0;
  tricep_repetitions_count = 0;
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
  Timer? _connectionTimeoutTimer;

  @override
  void dispose() {
    _notifySub?.cancel();
    _connectSub?.cancel();
    _scanSub?.cancel();
    _connectionTimeoutTimer?.cancel();
    super.dispose();
  }

  void _onScanUpdate(DiscoveredDevice d) {
    if (d.name == 'BLE-TEMP' && !_found) {
      _found = true;
      _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          _connectionTimeoutTimer?.cancel();
          setState(() {
            isBluetoothConnected.value = true;
            _isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkingPage(onEndWorkout: _disconnect)),
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
    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse('00000000-5EC4-4083-81CD-A10B8D5CF6EC'),
      characteristicId: Uuid.parse('00000001-5EC4-4083-81CD-A10B8D5CF6EC'),
    );

    _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) {
      setState(() {
        value = const Utf8Decoder().convert(bytes);
        _parseAndSaveRepetitions(value);
      });
    });
  }

  void _disconnect() {
    _connectSub?.cancel();
    _notifySub?.cancel();
    setState(() {
      isBluetoothConnected.value = false;
      _isLoading = false;
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
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(Duration(seconds: 10), () {
      if (!_found) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No device found')),
        );
      }
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
