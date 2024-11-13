import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const CurrentWeatherCard({required this.data, Key? key}) : super(key: key);

  @override
  _CurrentWeatherCardState createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  // Create a PageController to control page navigation
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Current Weather in ${widget.data['name']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // PageView with arrows
            SizedBox(
              height: 200, // Adjust height for the sliding section
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController, // Set the controller to navigate pages
                    children: [
                      // Feels Like Section
                      _buildFeelsLikeSection(),
                      // Humidity Section
                      _buildHumiditySection(),
                      // Wind Section
                      _buildWindSection(),
                    ],
                  ),
                  // Left arrow
                  Positioned(
                    left: 8,
                    top: 80,
                    child: IconButton(
                      icon: Icon(Icons.arrow_left, color: Colors.blue[800],size: 40,),
                      onPressed: () {
                        // Go to the previous page (if not already on the first page)
                        if (_pageController.page! > 0) {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 8,
                    top: 80,
                    child: IconButton(
                      icon: Icon(Icons.arrow_right, color: Colors.blue[800],size: 40,),
                      onPressed: () {
                        // Go to the next page (if not already on the last page)
                        if (_pageController.page! < 2) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.data['weather'][0]['description']}",
              style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelsLikeSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.thermostat, color: Colors.blue[800], size: 40),
        const SizedBox(height: 8),
        Text(
          "${widget.data['main']['temp']}°C",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Feels like: ${widget.data['main']['feels_like']}°C",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildHumiditySection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.opacity, color: Colors.blue[800], size: 40),
        const SizedBox(height: 8),
        Text(
          "Humidity: ${widget.data['main']['humidity']}%",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Pressure: ${widget.data['main']['pressure']} hPa",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildWindSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.air, color: Colors.blue[800], size: 40),
        const SizedBox(height: 8),
        Text(
          "Wind: ${widget.data['wind']['speed']} m/s",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Direction: ${widget.data['wind']['deg']}°",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
