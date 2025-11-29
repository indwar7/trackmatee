import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';

class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({Key? key}) : super(key: key);

  void _showAddContactDialog(BuildContext context, ProfileController controller) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Add Trusted Contact',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contact Name',
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationshipController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Relationship (e.g., Friend, Family)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  relationshipController.text.isNotEmpty) {
                await controller.addTrustedContact(
                  name: nameController.text,
                  phoneNumber: phoneController.text,
                  relation: relationshipController.text,
                );
                Navigator.pop(context);
              } else {
                Get.snackbar('Error', 'Please fill all fields',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Trusted Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'You will be able to share your live location with one or more contacts during any Trackmate trip.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (profileController.trustedContacts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No trusted contacts added yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: profileController.trustedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = profileController.trustedContacts[index];
                    return Card(
                      color: const Color(0xFF2A2A3E),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF7C3AED),
                          child: Text(
                            contact.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          contact.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.phoneNumber,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              contact.relation,
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF2A2A3E),
                                title: const Text(
                                  'Remove Contact',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  'Are you sure you want to remove ${contact.name}?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel',
                                        style: TextStyle(color: Colors.white70)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await profileController.removeTrustedContact(contact.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Remove',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddContactDialog(context, profileController),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Add Contact',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}