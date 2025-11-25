import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TrustedContact {
  final String name;
  final String phoneNumber;
  final String relationship;
  final String? displayName;

  TrustedContact({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'relationship': relationship,
    'displayName': displayName ?? name,
  };

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    relationship: json['relationship'],
    displayName: json['displayName'] ?? json['name'],
  );
}

class TrustedContactsController extends GetxController {
  var trustedContacts = <TrustedContact>[].obs;
  final _storage = GetStorage();

  void addTrustedContact({
    required String name,
    required String phoneNumber,
    required String relationship,
  }) {
    final contact = TrustedContact(
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      displayName: name,
    );
    trustedContacts.add(contact);
    _saveContactsToStorage();
  }

  void removeTrustedContact(TrustedContact contact) {
    trustedContacts.remove(contact);
    _saveContactsToStorage();
  }

  void updateContact(int index, TrustedContact contact) {
    if (index >= 0 && index < trustedContacts.length) {
      trustedContacts[index] = contact;
      _saveContactsToStorage();
    }
  }

  bool hasContacts() {
    return trustedContacts.isNotEmpty;
  }

  void _saveContactsToStorage() {
    List<Map<String, dynamic>> contactsJson =
    trustedContacts.map((contact) => contact.toJson()).toList();
    _storage.write('trusted_contacts', contactsJson);
  }

  void _loadContactsFromStorage() {
    final storedContacts = _storage.read('trusted_contacts');
    if (storedContacts != null && storedContacts is List) {
      trustedContacts.value = (storedContacts as List)
          .map((contact) =>
          TrustedContact.fromJson(contact as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadContactsFromStorage();
  }

  @override
  void onClose() {
    super.onClose();
  }
}