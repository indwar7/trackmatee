import 'package:get/get.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {

  /// DEFAULT LOCATIONS
  var fromLocation = LocationModel(
    name: "Delhi, India",
    lat: 28.6139,
    lng: 77.2090,
  ).obs;

  var toLocation = LocationModel(
    name: "Gurgaon, Haryana",
    lat: 28.4595,
    lng: 77.0266,
  ).obs;


  /// SEARCH RESULTS FROM GOOGLE API
  RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;

  get homeAddress => null;

  get workAddress => null;


  /// SEARCH GOOGLE PLACES AUTOCOMPLETE
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final results = await LocationService.searchLocation(query);
    searchResults.assignAll(results);
  }


  /// SET FROM LOCATION USING PLACE_ID
  Future<void> setFromByPlaceId(String placeId) async {
    final d = await LocationService.getPlaceDetails(placeId);

    fromLocation.value = LocationModel(
      name: d["name"],
      lat: d["lat"],
      lng: d["lng"],
    );
  }


  /// SET TO LOCATION USING PLACE_ID
  Future<void> setToByPlaceId(String placeId) async {
    final d = await LocationService.getPlaceDetails(placeId);

    toLocation.value = LocationModel(
      name: d["name"],
      lat: d["lat"],
      lng: d["lng"],
    );
  }


  /// SWAP LOCATIONS
  void swapLocations() {
    final temp = fromLocation.value;
    fromLocation.value = toLocation.value;
    toLocation.value = temp;
  }

  void updateFromLocation(city, code) {}

  void updateToLocation(city, code) {}

  void updateHomeAddress(String address, String city) {}

  void updateWorkAddress(String address, String city) {}
}
