import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String locationName;
  final double latitude;
  final double longitude;
  final String timezone;
  final String weather;
  final String temperature;
  final String wind;
  final String sunrise;
  final String sunset;

  WeatherData({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.weather,
    required this.temperature,
    required this.wind,
    required this.sunrise,
    required this.sunset,
  });
}

class WeatherService {
  Future<WeatherData> fetchWeatherForPlace(String placeName) async {
    final geocodingUri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
          '?name=${Uri.encodeComponent(placeName)}'
          '&count=1'
          '&language=en'
          '&format=json',
    );

    final geocodingResponse = await http.get(geocodingUri);

    if (geocodingResponse.statusCode != 200) {
      throw Exception('Failed to search location');
    }

    final geocodingJson = jsonDecode(geocodingResponse.body);

    if (geocodingJson['results'] == null ||
        (geocodingJson['results'] as List).isEmpty) {
      throw Exception('No matching location found');
    }

    final location = geocodingJson['results'][0];
    final double latitude = (location['latitude'] as num).toDouble();
    final double longitude = (location['longitude'] as num).toDouble();
    final String timezone = location['timezone'];
    final String locationName = location['name'];

    final forecastUri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m'
          '&daily=sunrise,sunset'
          '&timezone=${Uri.encodeComponent(timezone)}',
    );

    final forecastResponse = await http.get(forecastUri);

    if (forecastResponse.statusCode != 200) {
      throw Exception('Failed to fetch weather');
    }

    final forecastJson = jsonDecode(forecastResponse.body);

    final current = forecastJson['current'];
    final daily = forecastJson['daily'];

    final double temperatureValue =
    (current['temperature_2m'] as num).toDouble();
    final double windSpeedValue =
    (current['wind_speed_10m'] as num).toDouble();
    final int windDirectionValue =
    (current['wind_direction_10m'] as num).toInt();
    final int weatherCode = (current['weather_code'] as num).toInt();

    final List sunriseList = daily['sunrise'];
    final List sunsetList = daily['sunset'];

    return WeatherData(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      weather: weatherCodeToText(weatherCode),
      temperature: '${temperatureValue.toStringAsFixed(1)}°C',
      wind:
      '${windSpeedValue.toStringAsFixed(1)} km/h ${windDirectionToCompass(windDirectionValue)}',
      sunrise: formatIsoTime(sunriseList.first.toString()),
      sunset: formatIsoTime(sunsetList.first.toString()),
    );
  }

  String formatIsoTime(String isoString) {
    if (isoString.contains('T')) {
      return isoString.split('T')[1].substring(0, 5);
    }
    return isoString;
  }

  String windDirectionToCompass(int degrees) {
    const directions = [
      'N',
      'NE',
      'E',
      'SE',
      'S',
      'SW',
      'W',
      'NW',
    ];
    final index = ((degrees % 360) / 45).round() % 8;
    return directions[index];
  }

  String weatherCodeToText(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }
}