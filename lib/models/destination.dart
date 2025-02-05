import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Destination {
  final LatLng from;
  final LatLng destination;
  final Timestamp time;

  Destination({
    required this.from,
    required this.destination,
    required this.time,
  });

  // Update the fromJson constructor to handle GeoPoint to LatLng conversion
  Destination.fromJson(Map<String, Object?> json)
      : this(
    from: LatLng(
      (json['from'] as GeoPoint).latitude,
      (json['from'] as GeoPoint).longitude,
    ),
    destination: LatLng(
      (json['destination'] as GeoPoint).latitude,
      (json['destination'] as GeoPoint).longitude,
    ),
    time: json['arrive_time']! as Timestamp,
  );

  Map<String, Object?> toJson() {
    return {
      "from": GeoPoint(from.latitude, from.longitude), // Convert LatLng to GeoPoint
      "destination": GeoPoint(destination.latitude, destination.longitude),
      "arrive_time": time,
    };
  }
}
