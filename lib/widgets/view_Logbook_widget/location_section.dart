import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'detail_item.dart';

class LogBookLocationSection extends StatefulWidget {
  final BuildContext context;
  final Map<String, dynamic> data;

  LogBookLocationSection(
      {super.key, required this.context, required this.data});

  @override
  State<LogBookLocationSection> createState() => _LogBookLocationSectionState();
}

class _LogBookLocationSectionState extends State<LogBookLocationSection> {
  // StreamSubscription<Position>? _positionStream; // For location updates
  LatLng? _currentLocation; // Store current location
  final PopupController _popupController = PopupController(); // Manage popups
  List<LatLng> points = [];
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch the user's current location on load
  }

  // Fetches the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } else {
      // Handle case when permission is denied
      print("Location permissions are denied.");
    }
  }

// Method to retrieve markers including current and evacuation location
  List<Marker> getMarkers() {
    final GeoPoint location = widget.data["location"];
    final double latitude = location.latitude;
    final double longitude = location.longitude;

    List<Marker> markers = [
      Marker(
        point: LatLng(latitude, longitude),
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
        key: const Key('reportIncidentMarker'),
      ),
    ];

    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
          key: const Key('currentLocationMarker'),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint location = widget.data["location"];
    final double latitude = location.latitude;
    final double longitude = location.longitude;
    return Container(
      padding: EdgeInsets.all(12),
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogBookDetailItem(
              label: "Assigned Responder",
              value: widget.data["primaryResponderDisplayName"]),
          Text("Track Location", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),

          // Use Stack to overlay content on FlutterMap
          Stack(
            children: [
              // Container wrapping FlutterMap with a fixed size
              Container(
                height: 200, // Set desired map height
                width:
                    double.infinity, // Match the width of the parent container
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 15,
                    // maxZoom: 20,
                    // minZoom: 13,
                    onTap: (_, __) => _popupController.hideAllPopups(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylineCulling: false,
                      polylines: [
                        Polyline(
                            points: points,
                            color: Colors.black,
                            strokeWidth: 5),
                      ],
                    ),
                    MarkerLayer(
                      markers: getMarkers(),
                    ),
                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        markers: getMarkers(),
                        popupController: _popupController,
                        markerTapBehavior: MarkerTapBehavior.togglePopup(),
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            if (marker.key ==
                                const Key('reportIncidentMarker')) {
                              return Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(8.0),
                                child: SelectableText(
                                    'Address: ${widget.data['address']}'),
                              );
                            } else if (marker.key ==
                                const Key('currentLocationMarker')) {
                              return Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text('You are here'),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned widget for overlay button
              Positioned(
                top: 10,
                right: 50,
                child: IconButton(
                  icon: Icon(Icons.my_location, color: Colors.blue),
                  onPressed: () {
                    if (_currentLocation != null) {
                      mapController.move(_currentLocation!, 15.0);
                    }
                  },
                ),
              ),
              // Icon button to center map on report location
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.location_pin, color: Colors.red),
                  onPressed: () {
                    mapController.move(LatLng(latitude, longitude), 15.0);
                  },
                ),
              ),
            ],
          ),

          GestureDetector(
            onTap: _showGPLConfirmationDialog,
            child: FlutterLogo(size: 30),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showGPLConfirmationDialog() {
    showDialog(
      context: widget.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('GPL License Acknowledgment'),
          content: const Text(
              'This app uses the flutter_map_tile_caching package, which is licensed under the GPL.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
