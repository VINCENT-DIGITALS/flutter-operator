import 'package:flutter/material.dart';
import 'buildForecast.dart';
import 'currentweather.dart';
import 'weatherService.dart';

class WeatherDialog extends StatefulWidget {
  const WeatherDialog({super.key});

  @override
  _WeatherDialogState createState() => _WeatherDialogState();
}

class _WeatherDialogState extends State<WeatherDialog> {
  Map<String, dynamic>? _currentWeatherData;
  List<dynamic>? _forecastData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weatherService = WeatherService();
      final currentWeather = await weatherService.fetchCurrentWeather();
      final forecast = await weatherService.fetchForecast();

      setState(() {
        _currentWeatherData = currentWeather;
        _forecastData = forecast;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching weather data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Define responsive width and height using constraints
          double dialogWidth = constraints.maxWidth * 0.8; // 80% of screen width
          double dialogHeight = constraints.maxHeight * 0.8; // 80% of screen height

          // Ensure the dialog does not exceed a certain size
          if (dialogWidth > 600) dialogWidth = 600; // Max width of 600
          if (dialogHeight > 600) dialogHeight = 600; // Max height of 600

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[200]!, Colors.blue[900]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Weather Overview",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_currentWeatherData != null)
                              CurrentWeatherCard(data: _currentWeatherData!),
                            const SizedBox(height: 20),
                            Text(
                              "5-Day Forecast",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_forecastData != null)
                              ForecastList(data: _forecastData!),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
