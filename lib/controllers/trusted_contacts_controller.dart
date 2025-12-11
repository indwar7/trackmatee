// 📌 lib/controllers/trusted_contacts_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class TrustedContactsController extends GetxController {
  final _storage = GetStorage();
  final _uuid = const Uuid();

  final _trustedContacts = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get trustedContacts => _trustedContacts;

  @override
  void onInit() {
    super.onInit();
    loadTrustedContacts();
  }

  // Load trusted contacts from storage
  void loadTrustedContacts() {
    final stored = _storage.read<List>('trusted_contacts');
    if (stored != null) {
      _trustedContacts.value =
          stored.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  // Add a trusted contact
  void addTrustedContact(String name, String phone) {
    final contact = {
      'id': _uuid.v4(),
      'name': name,
      'phone': phone,
      'addedAt': DateTime.now().toIso8601String(),
    };

    _trustedContacts.add(contact);
    _saveTrustedContacts();
  }

  // Remove a trusted contact
  void removeTrustedContact(String id) {
    _trustedContacts.removeWhere((contact) => contact['id'] == id);
    _saveTrustedContacts();
  }

  // Save trusted contacts to storage
  void _saveTrustedContacts() {
    _storage.write('trusted_contacts', _trustedContacts.toList());
  }

  // Clear all trusted contacts
  void clearTrustedContacts() {
    _trustedContacts.clear();
    _storage.remove('trusted_contacts');
  }
}