import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps/models/destination.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String DESTINATION_COLLECTION_REF = "destinations";

class DatabaseService {
  final _firebase = FirebaseFirestore.instance;

  late final CollectionReference _destinationRef;

  DatabaseService() {
    _destinationRef = _firebase
        .collection(DESTINATION_COLLECTION_REF)
        .withConverter<Destination>(
            fromFirestore: (snapshots, _) => Destination.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (destination, _) => destination.toJson());
  }

  Stream<List<Destination>> getDestinations() {
    return FirebaseFirestore.instance
        .collection('destinations')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data()
                  as Map<String, dynamic>; // Cast to Map<String, dynamic>
              return Destination.fromJson(data); // Convert to Destination
            }).toList());
  }

  Future<void> addDestination(LatLng from, LatLng destination) async {
    try {
      await _firebase.collection('destinations').add({
        'from': GeoPoint(from.latitude, from.longitude),
        'destination': GeoPoint(destination.latitude, destination.longitude),
        'arrive_time': Timestamp.now(), // Example: Current timestamp
      });
    } catch (e) {
      print("Error adding destination: $e");
      throw Exception("Failed to add destination");
    }
  }
}

//StreamProvider to fetch data from Firebase
final destinationsProvider = StreamProvider<List<Destination>>((ref) {
  return FirebaseFirestore.instance
      .collection('destinations')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Destination.fromJson(data);
          }).toList());
});
