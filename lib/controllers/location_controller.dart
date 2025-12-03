import 'package:get/get.dart';

class LocationModel {
  final String city;
  final String code;

  LocationModel({required this.city, required this.code});
}

class AddressModel {
  final String address;
  final String city;

  AddressModel({required this.address, required this.city});
}

class LocationController extends GetxController {
  var fromLocation = LocationModel(city: 'DELHI', code: 'NDLS').obs;
  var toLocation = LocationModel(city: 'Gurgaon', code: 'GRG').obs;

  var homeAddress = AddressModel(
    address: 'Shanti Nagar-3',
    city: 'Delhi, India',
  ).obs;

  var workAddress = AddressModel(
    address: 'Cyber city phase 3, Gurgaon',
    city: 'Haryana, India',
  ).obs;

  void swapLocations() {
    final temp = fromLocation.value;
    fromLocation.value = toLocation.value;
    toLocation.value = temp;
  }

  void updateFromLocation(String city, String code) {
    fromLocation.value = LocationModel(city: city, code: code);
  }

  void updateToLocation(String city, String code) {
    toLocation.value = LocationModel(city: city, code: code);
  }

  void updateHomeAddress(String address, String city) {
    homeAddress.value = AddressModel(address: address, city: city);
  }

  void updateWorkAddress(String address, String city) {
    workAddress.value = AddressModel(address: address, city: city);
  }
}