import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../service/weather.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();

  String locationName = 'Not connected yet';
  String weather = '--';
  String temperature = '--';
  String wind = '--';
  String summary = '--';

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCurrentLocationWeather();
  }

  Future<void> loadCurrentLocationWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();

      String resolvedLocationName =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final parts = <String>[
            if ((place.locality ?? '').isNotEmpty) place.locality!,
            if ((place.administrativeArea ?? '').isNotEmpty) place.administrativeArea!,
            if ((place.country ?? '').isNotEmpty) place.country!,
          ];

          if (parts.isNotEmpty) {
            resolvedLocationName = parts.join(', ');
          }
        }
      } catch (_) {
      }

      final data = await _weatherService.fetchWeatherForCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: resolvedLocationName,
      );


      setState(() {
        locationName = data.locationName;
        weather = data.weather;
        temperature = data.temperature;
        wind = data.wind;
        summary = buildFishingSummary(
          weatherText: data.weather,
          windText: data.wind,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String buildFishingSummary({
    required String weatherText,
    required String windText,
  }) {
    final lowerWeather = weatherText.toLowerCase();
    final windValue = extractWindSpeed(windText);

    if (lowerWeather.contains('thunderstorm') ||
        lowerWeather.contains('snow') ||
        windValue >= 25) {
      return 'Poor conditions. Consider choosing a sheltered spot or postponing the session.';
    }

    if (lowerWeather.contains('rain') || windValue >= 15) {
      return 'Fair conditions. Fishable, but wind or rain may affect comfort and casting.';
    }

    return 'Good conditions for a short fishing session near you.';
  }

  double extractWindSpeed(String windText) {
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(windText);

    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0;
    }

    return 0;
  }

  Widget buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0277BD)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D2B3E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0277BD),
            Color(0xFF00A6D6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phishing,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                color: Colors.white,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.my_location, color: Color(0xFF0277BD)),
                  SizedBox(width: 8),
                  Text(
                    'Current Location Check',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2B3E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (isLoading) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
                const Text(
                  'Checking your local fishing conditions...',
                  style: TextStyle(color: Colors.black54),
                ),
              ] else ...[
                Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],

              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: isLoading ? null : loadCurrentLocationWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh conditions'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today Quick Check',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2B3E),
                ),
              ),

              const SizedBox(height: 16),

              buildInfoTile(
                icon: Icons.cloud_outlined,
                label: 'Weather',
                value: weather,
              ),

              const SizedBox(height: 10),

              buildInfoTile(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: temperature,
              ),

              const SizedBox(height: 10),

              buildInfoTile(
                icon: Icons.air,
                label: 'Wind',
                value: wind,
              ),

              const SizedBox(height: 16),

              buildSummaryCard(),
            ],
          ),
        ),
      ],
    );
  }
}