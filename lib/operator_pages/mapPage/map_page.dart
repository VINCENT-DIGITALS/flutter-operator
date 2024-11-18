import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/appbar_navigation.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/location_service.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'weatherDialog.dart';
import 'weatherService.dart';

class MapPageMain extends StatefulWidget {
  const MapPageMain({super.key});

  @override
  State<MapPageMain> createState() => _MapPageMainState();
}

class _MapPageMainState extends State<MapPageMain> {
  final MapController mapController = MapController();
  final PopupController _popupController = PopupController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WeatherService _weatherService = WeatherService(); // Singleton instance
  StreamSubscription<Position>? _positionStream;

  bool isLoading = true;
  final LatLng _initialLocation = LatLng(15.713860511440583, 120.900871019045);
  final double _initialZoom = 8;

  // Define base map styles
  final Map<String, String> _baseMaps = {
    'Standard':
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Removed subdomains
  };

  // Track selected base map layer
  String _selectedBaseMap = 'Standard';

  final Map<String, String> _weatherLayers = {
    'Clouds': 'clouds_new',
    'Precipitation': 'precipitation_new',
    'Sea Level Pressure': 'pressure_new',
    'Wind Speed': 'wind_new',
    'Temperature': 'temp_new',
  };

  Map<String, bool> _selectedLayers = {
    'clouds_new': false,
    'precipitation_new': false,
    'pressure_new': false,
    'wind_new': false,
    'temp_new': false,
  };

  @override
  void initState() {
    super.initState();
    _weatherService
        .resetTimer(); // Fetch weather data and reset timer on page visit
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    const String weatherApiKey = '9acdac93d3d4fcf28f9259eebce8952c';

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        isLargeScreen: isLargeScreen,
        scaffoldKey: _scaffoldKey,
        title: 'Weather Map',
      ),
      drawer: isLargeScreen
          ? null
          : CustomDrawer(scaffoldKey: _scaffoldKey, currentRoute: '/map'),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              key: ValueKey(_selectedLayers.toString() +
                  _selectedBaseMap), // Rebuild map when layer changes
              mapController: mapController,
              options: MapOptions(
                initialCenter: _initialLocation,
                initialZoom: _initialZoom,
                minZoom: 5,
                onTap: (_, __) => _popupController.hideAllPopups(),
              ),
              children: [
                // Base map layer (Standard or Grayscale)
                TileLayer(
                  urlTemplate: _baseMaps[_selectedBaseMap]!,
                  // tileProvider: CancellableTileProvider(),
                  userAgentPackageName: 'com.example.app',
                ),

                ..._selectedLayers.entries
                    .where((entry) =>
                        entry.value &&
                        mapController.camera.zoom >
                            5) // Limit zoom level for weather layers
                    .map((entry) => TileLayer(
                          urlTemplate:
                              'https://tile.openweathermap.org/map/${entry.key}/{z}/{x}/{y}.png?appid=$weatherApiKey',
                          userAgentPackageName: 'com.example.app',
                        ))
                    .toList(),
              ],
            ),

          if (isLargeScreen)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: SizedBox(
                width: 250,
                child: CustomDrawer(
                  scaffoldKey: _scaffoldKey,
                  currentRoute: '/map',
                ),
              ),
            ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'mapSelectionButton', // Unique heroTag for this button
              onPressed: () {
                _showBaseMapSelectionModal(context);
              },
              child: const Icon(Icons.map),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'layerSelectionButton', // Unique heroTag for this button
              onPressed: () {
                _showLayerSelectionModal(context);
              },
              child: const Icon(Icons.layers),
            ),
          ),
          // Inside the Stack in MapPageMain
          Positioned(
            bottom: 140,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const WeatherDialog(),
                );
              },
              child: const Icon(Icons.cloud),
            ),
          ),
        ],
      ),
    );
  }

  // Base Map Selection Modal
  void _showBaseMapSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Base Map',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._baseMaps.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.key),
                value: entry.key,
                groupValue: _selectedBaseMap,
                onChanged: (String? value) {
                  setState(() {
                    _selectedBaseMap = value ?? 'Standard';
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void _showLayerSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Weather Layers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._weatherLayers.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.key),
                value: _selectedLayers[entry.value],
                onChanged: (bool? isSelected) {
                  setState(() {
                    _selectedLayers[entry.value] = isSelected ?? false;
                  });
                  Navigator.pop(context);
                  _showLayerSelectionModal(context);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
