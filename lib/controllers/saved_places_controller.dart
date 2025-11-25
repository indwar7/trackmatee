import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SavedPlace {
  final String name;
  final String address;
  final String type; // 'home', 'work', 'other'

  SavedPlace({
    required this.name,
    required this.address,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'type': type,
  };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
    name: json['name'],
    address: json['address'],
    type: json['type'],
  );
}

class SavedPlacesController extends GetxController {
  var savedPlaces = <SavedPlace>[].obs;
  var homeAddress = Rx<String?>(null);
  var workAddress = Rx<String?>(null);
  final _storage = GetStorage();

  void addPlace(SavedPlace place) {
    savedPlaces.add(place);
    _savePlacesToStorage();
  }

  void removePlace(int index) {
    if (index >= 0 && index < savedPlaces.length) {
      savedPlaces.removeAt(index);
      _savePlacesToStorage();
    }
  }

  void updatePlace(int index, SavedPlace place) {
    if (index >= 0 && index < savedPlaces.length) {
      savedPlaces[index] = place;
      _savePlacesToStorage();
    }
  }

  void saveHomeAddress(String address) {
    homeAddress.value = address;
    _storage.write('home_address', address);
  }

  void saveWorkAddress(String address) {
    workAddress.value = address;
    _storage.write('work_address', address);
  }

  List<SavedPlace> getPlacesByType(String type) {
    return savedPlaces.where((place) => place.type == type).toList();
  }

  void _savePlacesToStorage() {
    List<Map<String, dynamic>> placesJson =
    savedPlaces.map((place) => place.toJson()).toList();
    _storage.write('saved_places', placesJson);
  }

  void _loadPlacesFromStorage() {
    final storedPlaces = _storage.read('saved_places');
    if (storedPlaces != null && storedPlaces is List) {
      savedPlaces.value = (storedPlaces as List)
          .map((place) => SavedPlace.fromJson(place as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved addresses
    final savedHome = _storage.read('home_address');
    final savedWork = _storage.read('work_address');

    if (savedHome != null) {
      homeAddress.value = savedHome;
    } else {
      homeAddress.value = 'Indirapuram-1, Sector-8, Delhi, India';
    }

    if (savedWork != null) {
      workAddress.value = savedWork;
    } else {
      workAddress.value = 'Cyber city phase 3, Gurgaon, Haryana, India';
    }

    _loadPlacesFromStorage();

    // Initialize with default places if empty
    if (savedPlaces.isEmpty) {
      savedPlaces.addAll([
        SavedPlace(
          name: 'Home',
          address: homeAddress.value ?? 'Indirapuram-1, Sector-8, Delhi, India',
          type: 'home',
        ),
        SavedPlace(
          name: 'Work',
          address: workAddress.value ?? 'Cyber city phase 3, Gurgaon, Haryana, India',
          type: 'work',
        ),
      ]);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}