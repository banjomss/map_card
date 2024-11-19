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
  final ScrollController _scrollController = ScrollController();

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
    McDonaldsLocation(
      name: 'McDonald\'s Surrey Starbucks',
      lat: 49.186783508168915,
      lng: -122.8369779895335,
      address: '10200 King George Blvd, Surrey, BC V3T 5X5',
    ),
    McDonaldsLocation(
      name: 'McDonald\'s Guildford Bridge',
      lat: 49.18280035256553,
      lng: -122.8307981800432,
      address: '10355 152 St, Surrey, BC V3R 4G3',
    ),
    McDonaldsLocation(
      name: 'McDonald\'s Newton Aux',
      lat: 49.188129854456626,
      lng: -122.82444670917819,
      address: '7130 120 St, Surrey, BC V3W 3M8',
    ),
  ];

  void _animateToLocation(McDonaldsLocation location) {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(location.lat, location.lng)),
    );
  }

  void _scrollToLocationInList(McDonaldsLocation location) {
    int index = _locations.indexOf(location);
    if (index != -1) {
      _scrollController.animateTo(
        index * 100.0, // Adjust for item height (100.0 as an estimate)
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
                        context.read<LocationCubit>().selectLocation(location);
                        _scrollToLocationInList(location);
                      },
                    ))
                .toSet(),
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3, // Display halfway initially
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    final selectedLocation =
                        state is LocationSelectedState ? state.location : null;
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: _locations.length,
                      itemBuilder: (context, index) {
                        final location = _locations[index];
                        final isSelected = location == selectedLocation;
                        return Card(
                          color: isSelected ? Colors.blue[50] : Colors.white,
                          elevation: 4.0,
                          child: ListTile(
                            title: Text(location.name),
                            subtitle: Text(location.address),
                            onTap: () {
                              context
                                  .read<LocationCubit>()
                                  .selectLocation(location);
                              _animateToLocation(location);
                              _scrollToLocationInList(location);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
