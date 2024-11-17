import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'blocs/location_cubit.dart';
import 'models/mcdonalds_location.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => LocationCubit(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'McDonald\'s Locations in Surrey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: McDonaldsMap(),
    );
  }
}

class McDonaldsMap extends StatefulWidget {
  @override
  _McDonaldsMapState createState() => _McDonaldsMapState();
}

class _McDonaldsMapState extends State<McDonaldsMap> {
  late GoogleMapController _mapController;

  // Define the locations of the McDonald's in Surrey
  final List<McDonaldsLocation> _locations = [
    McDonaldsLocation(
      name: 'McDonald\'s Surrey Central',
      lat: 49.1913,
      lng: -122.8490,
      address: '10200 King George Blvd, Surrey, BC V3T 5X5',
    ),
    McDonaldsLocation(
      name: 'McDonald\'s Guildford',
      lat: 49.1833,
      lng: -122.8492,
      address: '10355 152 St, Surrey, BC V3R 4G3',
    ),
    McDonaldsLocation(
      name: 'McDonald\'s Newton',
      lat: 49.1650,
      lng: -122.8395,
      address: '7130 120 St, Surrey, BC V3W 3M8',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('McDonald\'s Locations in Surrey')),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(49.1913, -122.8490), // Center of Surrey
              zoom: 12.0,
            ),
            markers: _locations
                .map((location) => Marker(
                      markerId: MarkerId(location.name),
                      position: LatLng(location.lat, location.lng),
                      infoWindow: InfoWindow(title: location.name),
                      onTap: () {
                        context.read<LocationCubit>().selectLocation(location); // Dispatch the location selection event
                      },
                    ))
                .toSet(),
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Bottom Card View
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: BlocBuilder<LocationCubit, LocationState>(
              builder: (context, state) {
                if (state is LocationSelectedState) {
                  return Container(
                    height: 250.0,
                    child: ListView(
                      children: [
                        Card(
                          elevation: 4.0,
                          child: ListTile(
                            title: Text(state.location.name),
                            subtitle: Text(state.location.address),
                          ),
                        ),
                        ..._locations.map((location) {
                          return Card(
                            elevation: 4.0,
                            child: ListTile(
                              title: Text(location.name),
                              subtitle: Text(location.address),
                              onTap: () {
                                context.read<LocationCubit>().selectLocation(location);
                                // Optionally, animate the map camera to the location
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLng(
                                    LatLng(location.lat, location.lng),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    height: 250.0,
                    child: ListView(
                      children: [
                        ..._locations.map((location) {
                          return Card(
                            elevation: 4.0,
                            child: ListTile(
                              title: Text(location.name),
                              subtitle: Text(location.address),
                              onTap: () {
                                context.read<LocationCubit>().selectLocation(location);
                                // Optionally, animate the map camera to the location
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLng(
                                    LatLng(location.lat, location.lng),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
