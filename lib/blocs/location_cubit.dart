import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/mcdonalds_location.dart';

// Step 1: Define the States for the Cubit
abstract class LocationState {}

class LocationInitialState extends LocationState {}

class LocationSelectedState extends LocationState {
  final McDonaldsLocation location;

  LocationSelectedState(this.location);
}

// Step 2: Define the Cubit
class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitialState());

  // Method to select a location
  void selectLocation(McDonaldsLocation location) {
    emit(LocationSelectedState(location));
  }
}
