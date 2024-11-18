import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherService {
  static const String weatherApiKey = '9acdac93d3d4fcf28f9259eebce8952c';
  static const double latitude = 15.7295;
  static const double longitude = 120.8729;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final ValueNotifier<String> countdownNotifier =
      ValueNotifier<String>('02:00:00');
  Timer? _timer; // Use nullable Timer
  int _secondsLeft = 7200; // 2 hours in seconds

  void startFetchingWeather() {
    // Only start the timer if it hasn't been started
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          countdownNotifier.value = _formatDuration(_secondsLeft);
        } else {
          countdownNotifier.value = 'Fetching weather data now...';
          _secondsLeft = 7200; // Reset to 2 hours after fetch
          _fetchAndStoreWeatherData();
        }
      });
    }
  }

  String _formatDuration(int seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = ((seconds % 3600) / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Stop fetching if needed (optional)
  void stopFetchingWeather() {
    _timer?.cancel();
  }

  void resetTimer() {
    _timer?.cancel();
    _secondsLeft = 7200;
    startFetchingWeather(); // Restart the timer
    _fetchAndStoreWeatherData();
  }

// Fetch current weather data and store it in Firestore
  Future<void> _fetchAndStoreWeatherData() async {
    try {
      print("Starting weather data fetch...");

      // Fetch current weather and forecast
      final currentWeather = await fetchCurrentWeather();
      print("Current weather data fetched successfully.");

      final forecast = await fetchForecast();
      print("Weather forecast data fetched successfully.");

      // Get today's date for comparison
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Store the current weather data
      await _firestore.collection('weather').doc('current').set({
        'currentWeather': currentWeather,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Current weather data stored in Firestore with timestamp.");

      for (int i = 0; i < 5; i++) {
        // Use fixed document names like forecast_1, forecast_2, etc.
        final forecastDocRef =
            _firestore.collection('weather').doc('forecast_${i + 1}');

        // Calculate the date for this forecast
        final forecastDay = todayDate.add(Duration(days: i));

        // Fetch the forecast for the day
        final dayForecast = _getForecastForDay(forecast, forecastDay);

        if (dayForecast != null) {
          // Update the existing document with merge (or create if needed)
          await forecastDocRef.set({
            'forecast': dayForecast,
            'date': forecastDay
                .toIso8601String(), // Save the associated date for context
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          print(
              "Forecast_${i + 1} updated for ${forecastDay.toIso8601String()}.");
        } else {
          print(
              "No forecast data available for forecast_${i + 1} (${forecastDay.toIso8601String()}).");
        }
      }

      print("Weather data fetch and store operation completed.");
    } catch (e) {
      print("Error fetching and storing weather data: $e");
    } finally {}
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
  List<dynamic>? _getForecastForDay(
      List<dynamic> forecast, DateTime forecastDay) {
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
