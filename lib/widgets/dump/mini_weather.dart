// import 'package:administrator/consts.dart';
// import 'package:administrator/services/weather_service.dart';
// import 'package:administrator/models/weather_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:weather/weather.dart';

// class MiniWeatherWidget extends StatefulWidget {
//   const MiniWeatherWidget({super.key});

//   @override
//   State<MiniWeatherWidget> createState() => _MiniWeatherWidgetState();
// }

// class _MiniWeatherWidgetState extends State<MiniWeatherWidget> {
//   late WeatherData weatherInfo;
//   bool isLoading = false;
//   late int apiCallCount; // Declare variable to store API call count

//   myWeather() {
//     isLoading = false;
//     WeatherServices().fetchWeather().then((value) {
//       setState(() {
//         weatherInfo = value;
//         isLoading = true;
//         // Update API call count when weather data is fetched
//         apiCallCount = WeatherServices().getApiCallCount();
//       });
//     });
//   }

//   @override
//   void initState() {
//     weatherInfo = WeatherData(
//       name: '',
//       temperature: WTemperature(current: 0.0),
//       humidity: 0,
//       wind: Wind(speed: 0.0),
//       feelsLike: 0,
//       pressure: 0,
//       seaLevel: 0,
//       weather: [],
//     );
//     myWeather();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String formattedDate = DateFormat('EEEE d, MMMM yyyy').format(DateTime.now());
//     String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

//     return Scaffold(
//       backgroundColor: Color(0xFFF8F9FF),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Center(
//           child: isLoading
//               ? WeatherDetail(
//                   weather: weatherInfo,
//                   formattedDate: formattedDate,
//                   formattedTime: formattedTime,
//                 )
//               : const CircularProgressIndicator(color: Colors.deepPurple),
//         ),
//       ),
//     );
//   }
// }

// class WeatherDetail extends StatelessWidget {
//   final WeatherData weather;
//   final String formattedDate;
//   final String formattedTime;
//   const WeatherDetail({
//     super.key,
//     required this.weather,
//     required this.formattedDate,
//     required this.formattedTime,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String iconUrl = 'http://openweathermap.org/img/wn/${weather.weather[0].icon}@2x.png';

//     return SingleChildScrollView(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               spreadRadius: 5,
//               blurRadius: 7,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(75),
//                 child: Image.network(
//                   iconUrl,
                  
//                   fit: BoxFit.fill,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 weather.name,
//                 style: TextStyle(
//                   fontSize: 30,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 formattedDate,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black54,
//                 ),
//               ),
//               Text(
//                 formattedTime,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (weather.weather.isNotEmpty)
//                 Text(
//                   weather.weather[0].description,
//                   style: TextStyle(
//                     fontSize: 24,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               const SizedBox(height: 30),
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//                   child: Column(
//                     children: [
//                       ResponsiveRow(
//                         children: [
//                           weatherInfoCard(
//                             icon: Icons.water_drop,
//                             title: "Humidity",
//                             value: "${weather.humidity}%",
//                           ),
//                           weatherInfoCard(
//                             icon: Icons.thermostat,
//                             title: "Temp",
//                             value: "${weather.temperature.current.toStringAsFixed(2)}°C",
//                           ),
//                           weatherInfoCard(
//                             icon: Icons.thermostat_auto,
//                             title: "Feels Like",
//                             value: "${weather.feelsLike.toStringAsFixed(2)}°C"
//                           ),
//                           weatherInfoCard(
//                             icon: Icons.wind_power,
//                             title: "Wind",
//                             value: "${weather.wind.speed}km/h",
//                           ),
//                           weatherInfoCard(
//                             icon: Icons.speed,
//                             title: "Pressure",
//                             value: "${weather.pressure}hPa",
//                           ),
//                           weatherInfoCard(
//                             icon: Icons.water,
//                             title: "Sea-Level",
//                             value: "${weather.seaLevel}m",
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Column weatherInfoCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: Colors.white,
//           size: 30,
//         ),
//         const SizedBox(height: 5),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//           ),
//         ),
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ResponsiveRow extends StatelessWidget {
//   final List<Widget> children;
//   const ResponsiveRow({required this.children});

//   @override
//   Widget build(BuildContext context) {
//     bool isSmallScreen = MediaQuery.of(context).size.width < 600;

//     return Wrap(
//       spacing: isSmallScreen ? 10 : 20,
//       runSpacing: 10,
//       alignment: WrapAlignment.spaceEvenly,
//       children: children.map((child) => isSmallScreen ? Expanded(child: child) : Flexible(child: child)).toList(),
//     );
//   }
// }
