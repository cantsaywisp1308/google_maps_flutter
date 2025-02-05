import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps/models/destination.dart';
import 'package:google_maps/pages/map_page.dart';
import 'package:google_maps/services/database_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final destinationsAsyncValue = ref.watch(destinationsProvider);

    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: destinationsAsyncValue.when(
              data: (destinations) => _placesListView(context, destinations),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(
                child: Text("Error loading destinations"),
              ),
            ),
          ),
          _navigationButton(context),
        ],
      )),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        "Home Page Destination",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  // Widget _buildUI() {
  //   return SafeArea(
  //     child: Column(
  //       children: [_placesListView(), _navigationButton()],
  //     ),
  //   );
  // }

  Widget _placesListView(BuildContext context, List<Destination> destinations) {
    if (destinations.isEmpty) {
      return const Center(
        child: Text("Go somewhere"),
      );
    }

    return ListView.builder(
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        Destination destination = destinations[index];
        return ListTile(
          tileColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
              "${destination.destination.latitude}, ${destination.destination.longitude}"),
          subtitle: Text(
              "${destination.from.latitude}, ${destination.from.longitude}"),
        );
      },
    );
  }

  Widget _navigationButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapPage(),
            ),
          );
        },
        child: const Text("Let's drive"),
      ),
    );
  }
}
