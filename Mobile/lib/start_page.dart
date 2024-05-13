import 'package:flutter/material.dart';
import 'package:smart_dumbbell_mobile/main.dart';
import 'package:smart_dumbbell_mobile/working_page.dart';


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
