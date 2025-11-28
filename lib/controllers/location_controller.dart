import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackmate_app/services/location_service.dart';
import 'package:geocoding/geocoding.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  Position? currentPosition;
  String? currentAddress;
  var isLoading = false.obs;
  
  RxString get currentLocation => (currentAddress ?? 'Loading...').obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading(true);
      currentPosition = await _locationService.getCurrentLocation();
      await _getAddressFromLatLng();
      update();
    } catch (e) {
      print(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _getAddressFromLatLng() async {
    if (currentPosition != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );
        Placemark place = placemarks[0];
        currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      } catch (e) {
        print(e);
      }
    }
  }
}
