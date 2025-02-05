import 'package:flutter/material.dart';
import 'package:google_maps/pages/home_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ArrivePage extends StatelessWidget {
  final LatLng from;
  final LatLng destination;
  const ArrivePage({super.key, required this.from, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("You have arrived"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Text(
            "You have arrived ${destination.latitude} ${destination.longitude} from ${from.latitude} ${from.longitude}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: Text("Home Page"))
        ],
      )),
    );
  }
}
