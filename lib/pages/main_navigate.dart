import 'package:flutter/material.dart';

import 'home.dart';
import 'spots.dart';
import 'log_trip.dart';
import 'trip_history.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _trips = [];

  void addTrip(Map<String, String> trip) {
    setState(() {
      _trips.insert(0, trip);
      _selectedIndex = 3; // switch to History tab after saving
    });
  }

  final List<String> titles = const [
    'Home',
    'Spots',
    'Log a Trip',
    'Trip History',
  ];

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return SpotsPage(onSaveTrip: addTrip);
      case 2:
        return LogTripPage(onSaveTrip: addTrip);
      case 3:
        return TripHistoryPage(trips: _trips);
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() {
            _selectedIndex = i;
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