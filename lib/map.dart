import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? currentPosition;
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    currentPosition = await _determinePosition();
    setState(() {
      currentPosition = currentPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("currentPosition: $currentPosition");
    return Scaffold(
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: LatLng(
            currentPosition?.latitude ?? 51.509364,
            currentPosition?.longitude ?? -0.128928,
          ), // Center the map over London, UK
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            // Bring your own tiles
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
            userAgentPackageName: "com.example.alarmbus",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  currentPosition?.latitude ?? 51.509364,
                  currentPosition?.longitude ?? -0.128928,
                ),
                child: Icon(
                  Icons.my_location_outlined,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Action when button is pressed
          print("currentPosition button pressed");
          currentPosition = await _determinePosition();
          setState(() {
            currentPosition = currentPosition;
          });
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
