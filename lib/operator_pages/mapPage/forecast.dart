import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastPage extends StatelessWidget {
  final List<dynamic> forecastData;

  const ForecastPage({super.key, required this.forecastData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("5-Day Forecast"),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          final forecast = forecastData[index];
          final dateTime = DateTime.parse(forecast['dt_txt']);
          final day = DateFormat('EEEE, MMM d').format(dateTime);
          final temperature = forecast['main']['temp'];
          final description = forecast['weather'][0]['description'];
          final iconCode = forecast['weather'][0]['icon'];
          final windSpeed = forecast['wind']['speed'];
          final humidity = forecast['main']['humidity'];

          return Card(
            color: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Temp: $temperature°C, $description\n"
                "Wind: $windSpeed m/s, Humidity: $humidity%",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
