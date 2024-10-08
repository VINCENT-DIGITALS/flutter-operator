import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:administrator/services/weather_service.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/models/weather_model.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late WeatherData weatherInfo;
  bool isLoading = false;
  late int apiCallCount;
  String role = 'Unknown';
  SharedPreferences? _prefs;
  Map<String, String> _userData = {};

  void myWeather() async {
    setState(() {
      isLoading = false;
    });

    WeatherData fetchedWeather = await WeatherServices().fetchWeather();

    setState(() {
      weatherInfo = fetchedWeather;
      isLoading = true;
      apiCallCount = WeatherServices().getApiCallCount();
    });

    await DatabaseService().saveWeatherData(weatherInfo);
  }

  @override
  void initState() {
    weatherInfo = WeatherData(
      name: '',
      temperature: WTemperature(current: 0.0),
      humidity: 0,
      wind: Wind(speed: 0.0),
      feelsLike: 0,
      pressure: 0,
      seaLevel: 0,
      weather: [],
    );
    myWeather();
    _initializePreferences();
    super.initState();
  }

  void _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _fetchAndDisplayUserData();
  }

  Future<void> _fetchAndDisplayUserData() async {
    try {
      _userData = {
        'uid': _prefs?.getString('uid') ?? '',
        'email': _prefs?.getString('email') ?? '',
        'displayName': _prefs?.getString('displayName') ?? '',
        'photoURL': _prefs?.getString('photoURL') ?? '',
        'phoneNum': _prefs?.getString('phoneNum') ?? '',
        'createdAt': _prefs?.getString('createdAt') ?? '',
        'address': _prefs?.getString('address') ?? '',
        'status': _prefs?.getString('status') ?? '',
        'role': _prefs?.getString('role') ?? '',
      };
      print('Role: ${_userData['role']}');
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE d, MMMM yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Define breakpoints for small, medium, and large screens
        bool isLargeScreen = constraints.maxWidth > 1000;  // Larger than 1000px (e.g., large desktops)
        bool isMediumScreen = constraints.maxWidth > 600 && constraints.maxWidth <= 1000;  // Between 600px and 1000px (e.g., tablets)
        bool isSmallScreen = constraints.maxWidth <= 600;  // Smaller than 600px (e.g., phones)

        double cardWidth;
        double cardHeight;
        double padding;
        double fontSize;

        if (isLargeScreen) {
          cardWidth = 500;
          cardHeight = 300;
          padding = 24;
          fontSize = 56;
        } else if (isMediumScreen) {
          cardWidth = constraints.maxWidth - 32;
          cardHeight = 250;
          padding = 20;
          fontSize = 48;
        } else {
          // Small screen adjustments
          cardWidth = constraints.maxWidth - 32;
          cardHeight = 200;
          padding = 16;
          fontSize = 40;
        }

        return isLoading
            ? Container(
                width: cardWidth,
                height: cardHeight,
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue.shade300,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$formattedDate, $formattedTime",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isLargeScreen ? 16 : 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      weatherInfo.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isLargeScreen ? 24 : 20),
                    ),
                    Text(
                      "${weatherInfo.temperature.current.toStringAsFixed(1)}°C",
                      style: TextStyle(
                          color: Colors.white, fontSize: fontSize),
                    ),
                    SizedBox(height: 5),
                    Text(
                      weatherInfo.weather.isNotEmpty
                          ? weatherInfo.weather[0].description
                          : '',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: isLargeScreen ? 18 : 16),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isLargeScreen ? 30 : 16,
                      children: [
                        _buildWeatherDetail('Humidity', "${weatherInfo.humidity}%", isLargeScreen),
                        _buildWeatherDetail('Wind', "${weatherInfo.wind.speed} km/h", isLargeScreen),
                        _buildWeatherDetail('Feels like', "${weatherInfo.feelsLike.toStringAsFixed(1)}°C", isLargeScreen),
                        _buildWeatherDetail('Pressure', "${weatherInfo.pressure} hPa", isLargeScreen),
                      ],
                    ),
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildWeatherDetail(String label, String value, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white70, fontSize: isLargeScreen ? 16 : 14),
        ),
        Text(
          value,
          style: TextStyle(
              color: Colors.white70, fontSize: isLargeScreen ? 16 : 14),
        ),
      ],
    );
  }
}
