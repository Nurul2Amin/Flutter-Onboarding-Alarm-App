// location_screen.dart
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../../alarms/presentation/home_screen.dart'; 

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _location = "Fetching location...";

  Future<void> _fetchLocation() async {
    final loc = await LocationService.getCurrentLocation();
    setState(() {
      _location = loc;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selected Location",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _location,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Button to go to the Alarm page, passing the location
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Navigate to the HomeScreen and pass the location
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(selectedLocation: _location),
                    ),
                  );
                },
                child: const Text("Go to Alarms"),
              ),
              // We'll keep the old 'Continue' button for now if you need it,
              // but you can remove it if the 'Go to Alarms' button is the replacement.
            ],
          ),
        ),
      ),
    );
  }
}