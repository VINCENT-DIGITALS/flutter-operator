import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastList extends StatefulWidget {
  final List<dynamic> data;

  const ForecastList({required this.data, Key? key}) : super(key: key);

  @override
  _ForecastListState createState() => _ForecastListState();
}

class _ForecastListState extends State<ForecastList> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 800; // For larger screens

    // Group the forecast data into days with three forecasts each (morning, afternoon, evening)
    List<List<dynamic>> groupedForecast = [];
    for (int i = 0; i < widget.data.length; i += 3) {
      groupedForecast.add(widget.data
          .sublist(i, i + 3 > widget.data.length ? widget.data.length : i + 3));
    }

    return Center(
      child: SizedBox(
        width: screenWidth * 0.9, // Adjust card width based on screen width
        height: screenHeight * 0.4, // Adjust card height based on screen height
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController, // Connect the PageController
              itemCount: groupedForecast.length,
              scrollDirection:
                  Axis.horizontal, // Horizontal scroll direction for sliding
              itemBuilder: (context, index) {
                final dayForecasts = groupedForecast[index];
                final dateTime = DateTime.parse(dayForecasts[0]['dt_txt']);
                final day = DateFormat('EEEE, MMM d').format(dateTime);

                return GestureDetector(
                  onTap: () {
                    // Handle the click action here (e.g., show detailed forecast)
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  600, // Set maximum width (you can adjust this value)
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://openweathermap.org/img/wn/${dayForecasts[0]['weather'][0]['icon']}@2x.png',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Weather for $day",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var forecast in dayForecasts)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                'https://openweathermap.org/img/wn/${forecast['weather'][0]['icon']}@2x.png',
                                                width: 40,
                                                height: 40,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Time: ${DateFormat('h:mm a').format(DateTime.parse(forecast['dt_txt']))}",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      "Temperature: ${forecast['main']['temp']}°C",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      "Description: ${forecast['weather'][0]['description']}",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      "Wind Speed: ${forecast['wind']['speed']} m/s",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      "Humidity: ${forecast['main']['humidity']}%",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("Close"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: MouseRegion(
                    onEnter: (_) => _showCursorOnHover(context),
                    onExit: (_) => _hideCursorOnExit(context),
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 8, // Adds subtle shadow for a floating effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight *
                              0.02, // Adjust padding based on screen height
                          horizontal: screenWidth *
                              0.03, // Adjust padding based on screen width
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "$day",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isWideScreen
                                    ? 20
                                    : 18, // Adjust font size for wide screens
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (var forecast in dayForecasts) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://openweathermap.org/img/wn/${forecast['weather'][0]['icon']}@2x.png',
                                    width: isWideScreen
                                        ? 50
                                        : 40, // Adjust icon size for wider screens
                                    height: isWideScreen ? 50 : 40,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${DateFormat('h:mm a').format(DateTime.parse(forecast['dt_txt']))}: ${forecast['main']['temp']}°C, ${forecast['weather'][0]['description']}",
                                      textAlign: TextAlign
                                          .center, // Center-aligns the day text
                                      style: TextStyle(
                                        fontSize: isWideScreen
                                            ? 16
                                            : 14, // Adjust font size for wide screens
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 8),
                            Icon(
                              Icons.info_outline, // Indicator for clickability
                              size: 30,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Left and Right Slide Arrow Icons
            Positioned(
              left: 10,
              top: screenHeight * 0.15, // Adjust position vertically
              child: GestureDetector(
                onTap: () {
                  if (_pageController.hasClients) {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Icon(
                  Icons.arrow_left,
                  size: 40,
                  color: Colors.blueAccent.withOpacity(0.7),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: screenHeight * 0.15, // Adjust position vertically
              child: GestureDetector(
                onTap: () {
                  if (_pageController.hasClients) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Icon(
                  Icons.arrow_right,
                  size: 40,
                  color: Colors.blueAccent.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCursorOnHover(BuildContext context) {
    // Change cursor on hover for clickable widget
    SystemMouseCursors.click;
  }

  void _hideCursorOnExit(BuildContext context) {
    // Hide cursor on exit
    SystemMouseCursors.basic;
  }
}
