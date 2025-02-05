import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/const.dart';
import 'package:google_maps/pages/arrive_page.dart';
import 'package:google_maps/pages/home_page.dart';
import 'package:google_maps/services/database_service.dart';
import 'package:google_maps/services/notification_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DatabaseService _databaseSevice = DatabaseService();
  // final TextEditingController _latitudeController = TextEditingController();
  // final TextEditingController _longitudeController = TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Location _locationController = new Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final TextEditingController _latitudeControllerFrom = TextEditingController();
  final TextEditingController _longitudeControllerFrom =
      TextEditingController();
  final TextEditingController _latitudeControllerTo = TextEditingController();
  final TextEditingController _longitudeControllerTo = TextEditingController();

  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  //static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentPosition = null;
  LatLng? destination = null;
  LatLng? departure;
  List<LatLng> departureDestination = [];

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
    // getLocationUpdates().then(
    //   (_) => {
    //     getPolyLinePoints(_pGooglePlex).then((coordinates) => {
    //           generatePolylineFromPoints(
    //               coordinates), //remember to have the API key billed
    //         }),
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: Text("Loading..."))
              : GoogleMap(
                  onMapCreated: ((GoogleMapController controller) =>
                      _mapController.complete(controller)),
                  initialCameraPosition: const CameraPosition(
                    target: _pGooglePlex,
                    zoom: 13,
                  ),
                  markers: _getMarkers(),
                  // markers: {
                  //   Marker(
                  //     markerId: const MarkerId("_currentLocation"),
                  //     icon: BitmapDescriptor.defaultMarker,
                  //     position: _currentPosition!,
                  //   ),
                  // Marker(
                  //   markerId: const MarkerId("_sourceLocation"),
                  //   icon: BitmapDescriptor.defaultMarker,
                  //   position: destination! != null : destination ? null,
                  // ),
                  // const Marker(
                  //   markerId: MarkerId("_destinationLocation"),
                  //   icon: BitmapDescriptor.defaultMarker,
                  //   position: _pApplePark,
                  // ),
                  //},
                  polylines: Set<Polyline>.of(polylines.values),
                ),
          Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  _inputRow(
                    label1: 'From Latitude',
                    label2: 'From Longitude',
                    controller1: _latitudeControllerFrom,
                    controller2: _longitudeControllerFrom,
                  ),
                  const SizedBox(height: 10),
                  _inputRow(
                    label1: 'To Latitude',
                    label2: 'To Longitude',
                    controller1: _latitudeControllerTo,
                    controller2: _longitudeControllerTo,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        departureDestination = [];
                        // Parse inputs for departure and destination
                        double fromLat =
                            double.parse(_latitudeControllerFrom.text.trim());
                        double fromLng =
                            double.parse(_longitudeControllerFrom.text.trim());
                        double toLat =
                            double.parse(_latitudeControllerTo.text.trim());
                        double toLng =
                            double.parse(_longitudeControllerTo.text.trim());

                        // Assign departure and destination
                        departure = LatLng(fromLat, fromLng);
                        departureDestination.add(departure!);
                        destination = LatLng(toLat, toLng);
                        departureDestination.add(destination!);

                        if (departure != null && destination != null) {
                          await _cameraPosition(departure!);
                          await getPolyLinePoints(departure!, destination!);
                        } else {
                          _showSnackBar('Please enter valid coordinates.');
                        }
                      } catch (e) {
                        _showSnackBar('Invalid input. Please try again.');
                      }
                    },
                    child: const Text('Find Route'),
                  )
                ],
              ))
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _inputRow({
    required String label1,
    required String label2,
    required TextEditingController controller1,
    required TextEditingController controller2,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller1,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label1,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller2,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label2,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Set<Marker> _getMarkers() {
    Set<Marker> markers = {};
    if (departure != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('departure'),
          position: departure!,
          infoWindow: const InfoWindow(title: 'Departure'),
        ),
      );
    }
    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination!,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );
    }

    return markers;
  }

  // Future<List<LatLng>> getPolyLinePoints(LatLng destinationPosition) async {
  //   List<LatLng> polylineCoordinates = [];
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     request: PolylineRequest(
  //         origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
  //         destination: PointLatLng(
  //             destinationPosition.latitude, destinationPosition.longitude),
  //         mode: TravelMode.driving),
  //     googleApiKey: GOOGLE_MAPS_API_KEY,
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   } else {
  //     print(result.errorMessage);
  //   }
  //   return polylineCoordinates;
  // }

  Future<void> getPolyLinePoints(LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
      googleApiKey: GOOGLE_MAPS_API_KEY,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      generatePolylineFromPoints(polylineCoordinates);
      _cameraPosition(destination);
    } else {
      print(result.errorMessage);
    }
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          departure =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _currentPosition = departure; // Also update current position
        });

        // Move the camera to the new position
        _cameraPosition(_currentPosition!);
      }

      checkProximity();
    });
  }

  Future<void> _cameraPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 16);
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> _animateCamera(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition cameraPosition = CameraPosition(target: position, zoom: 14);
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  // void initializeNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(android: initializationSettingsAndroid);
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  bool _hasNotified = false;
  Future<void> checkProximity() async {
    if (_currentPosition != null) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        destination!.latitude,
        destination!.longitude,
      );

      // Trigger notification if within 500 meters
      if (distance < 50 && _hasNotified == false) {
        _hasNotified = true;
        _databaseSevice.addDestination(departureDestination[0], destination!);
        // NotificationService().showNotification(
        //     title: 'You have arrived', body: 'You arrive your destination');
        // bool _hasNotified = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArrivePage(
              from: departureDestination[0],
              destination: destination!,
            ),
          ),
        );
      }
    }
  }
}
