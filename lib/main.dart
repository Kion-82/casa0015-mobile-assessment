import 'package:flutter/material.dart';

void main() {
  runApp(const CatchCheckApp());
}

class CatchCheckApp extends StatelessWidget {
  const CatchCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CatchCheck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.phishing,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CatchCheck',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Check fishing conditions and log your trips',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Go Fish'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SpotsPage(),
    LogTripPage(),
    TripHistoryPage(),
  ];

  final List<String> _titles = const [
    'Home',
    'Spots',
    'Log a Trip',
    'Trip History',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Spots',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Current Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Not connected yet'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today Quick Check',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('Date: --'),
                Text('Weather: --'),
                Text('Temperature: --'),
                Text('Wind: --'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SpotsPage extends StatelessWidget {
  const SpotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedSpots = <String>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Search fishing spot',
            hintText: 'Enter a place name',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spot Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Location: No spot selected'),
                const SizedBox(height: 8),
                const Text('Weather: --'),
                const Text('Temperature: --'),
                const Text('Wind: --'),
                const Text('Sunrise: --'),
                const Text('Sunset: --'),
                const Text('Summary: --'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        child: const Text('Save Spot'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null,
                        child: const Text('Log Trip Here'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Saved Spots',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (savedSpots.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.bookmark_border, size: 40, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No saved spots yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Search for a fishing location and save it here later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LogTripPage extends StatelessWidget {
  const LogTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Spot name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Date & time',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Auto-filled local condition',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Catch result',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.sentiment_satisfied_alt, size: 32),
                      SizedBox(height: 8),
                      Text('Caught'),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 32),
                      SizedBox(height: 8),
                      Text('No catch'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Add Photo'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trip saved (demo only)')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Save Trip'),
          ),
        ),
      ],
    );
  }
}

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = [
      {
        'date': '23 Apr 2026',
        'spot': 'Brighton Marina',
        'result': 'No catch',
      },
      {
        'date': '18 Apr 2026',
        'spot': 'Waterloo Bridge',
        'result': 'Caught fish',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Card(
          child: ListTile(
            title: Text('${trip['date']} - ${trip['spot']}'),
            subtitle: Text('${trip['result']}'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}