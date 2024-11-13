import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherService {
  static const String weatherApiKey = '9acdac93d3d4fcf28f9259eebce8952c';
  static const double latitude = 15.7295;
  static const double longitude = 120.8729;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

  // Start the periodic fetching when the app is launched
  void startFetchingWeather() {
    _timer = Timer.periodic(Duration(hours: 2), (_) {
      _fetchAndStoreWeatherData();
    });

    // Fetch data immediately at the start
    _fetchAndStoreWeatherData();
  }

  // Stop fetching if needed (optional)
  void stopFetchingWeather() {
    _timer?.cancel();
  }

  // Fetch current weather data and store it in Firestore
  Future<void> _fetchAndStoreWeatherData() async {
    try {
      final currentWeather = await fetchCurrentWeather();
      final forecast = await fetchForecast();

      // Get today's date for comparison
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Check if we already have stored forecast data for the next 5 days
      for (int i = 0; i < 5; i++) {
        final forecastDay = todayDate.add(Duration(days: i));

        // Check if forecast for this day already exists in Firestore
        final forecastDocRef = _firestore.collection('weather').doc('forecast_${forecastDay.toIso8601String()}');
        final forecastDocSnapshot = await forecastDocRef.get();

        if (!forecastDocSnapshot.exists) {
          // Extract forecast for this day
          final dayForecast = _getForecastForDay(forecast, forecastDay);

          if (dayForecast != null) {
            // Store forecast data for this day
            await forecastDocRef.set({
              'forecast': dayForecast,
              'timestamp': FieldValue.serverTimestamp(),
            });

            print("Weather data for ${forecastDay.toIso8601String()} stored in Firestore.");
          }
        } else {
          print("Forecast for ${forecastDay.toIso8601String()} already exists. Skipping.");
        }
      }

      // Store the current weather data
      await _firestore.collection('weather').doc('current').set({
        'currentWeather': currentWeather,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print("Error fetching and storing weather data: $e");
    }
  }

  // Fetch current weather data from OpenWeatherMap API
  Future<Map<String, dynamic>> fetchCurrentWeather() async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  // Fetch forecast data from OpenWeatherMap API
  Future<List<dynamic>> fetchForecast() async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['list'];
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  // Extract the forecast for a specific day
  List<dynamic>? _getForecastForDay(List<dynamic> forecast, DateTime forecastDay) {
    // We need to find the forecast for the exact day
    for (var forecastItem in forecast) {
      DateTime forecastTime = DateTime.parse(forecastItem['dt_txt']);
      
      // If the forecast is for the correct day, return the first available forecast of the day
      if (forecastTime.year == forecastDay.year &&
          forecastTime.month == forecastDay.month &&
          forecastTime.day == forecastDay.day) {
        return [forecastItem]; // Return as a list containing only this forecast
      }
    }
    return null; // No forecast found for the requested day
  }
}
