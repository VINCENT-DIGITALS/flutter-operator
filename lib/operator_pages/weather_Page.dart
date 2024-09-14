import 'package:administrator/widgets/appbar_navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:administrator/services/weather_service.dart';
import 'package:administrator/services/database_service.dart';
import 'package:administrator/models/weather_model.dart';
import 'package:administrator/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherData weatherInfo;
  bool isLoading = false;
  late int apiCallCount;
  String role = 'Unknown';
  SharedPreferences? _prefs;
  Map<String, String> _userData = {};

  // Method to fetch weather data and save it to the database
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

    // Save fetched weather data to the database
    await DatabaseService().saveWeatherData(weatherInfo);
  }

  late final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        bool isLargeScreen = constraints.maxWidth > 600;

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(isLargeScreen: isLargeScreen, scaffoldKey: _scaffoldKey, title: 'Weather',),
          drawer: isLargeScreen ? null : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/weather'),
          body: Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 250,
                  child: CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/weather'),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isLoading)
                        WeatherDetail(
                          weather: weatherInfo,
                           formattedDate: formattedDate,
                          formattedTime: formattedTime,
                        )
                      else
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final WeatherData weather;
  final String formattedDate;
  final String formattedTime;

  const WeatherDetail({
    super.key,
    required this.weather,
    required this.formattedDate,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 5),
          Text(
            weather.name,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "${weather.temperature.current.toStringAsFixed(1)}°C",
            style: const TextStyle(
              fontSize: 60,
              color: Colors.black,
              
            ),
          ),
          SizedBox(height: 5),
          Text(
            weather.weather[0].description,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              Tooltip(
                message: "The amount of water vapor in the air.",
                child: weatherInfoCard(
                  icon: Icons.water_drop,
                  title: "Humidity",
                  value: "${weather.humidity}%",
                ),
              ),
              Tooltip(
                message: "The temperature it actually feels like.",
                child: weatherInfoCard(
                  icon: Icons.thermostat,
                  title: "Feels Like",
                  value: "${weather.feelsLike.toStringAsFixed(1)}°C",
                ),
              ),
              Tooltip(
                message: "The speed of air movement.",
                child: weatherInfoCard(
                  icon: Icons.wind_power,
                  title: "Wind",
                  value: "${weather.wind.speed}km/h",
                ),
              ),
              Tooltip(
                message: "The force exerted by the atmosphere at a given point.",
                child: weatherInfoCard(
                  icon: Icons.speed,
                  title: "Pressure",
                  value: "${weather.pressure}hPa",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget weatherInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.blueAccent,
            size: 28,
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth ~/ 150;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}
