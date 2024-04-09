import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(MyApp());
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
        '/report': (context) => ReportPage(),
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
    ReportPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            label: 'Report',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
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
        title: Text('Smart Dubdbell'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkingPage()),
              );// Addclick functionality here
            },
            child: Text('START', style: TextStyle(fontSize: 50)),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(), // Make the button circular
              padding: EdgeInsets.all(120), // Adjust the size of the button
            ),
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

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Page'),
      ),
      body: Center(
        child: Text('This is the Report Page'),
      ),
    );
  }
}

class WorkingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Working Page'),
      ),
      body: Center(
        child: Text('This is the Working Page'),
      ),
    );
  }
}

