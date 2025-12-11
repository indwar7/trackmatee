import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  State<AadhaarVerificationScreen> createState() => _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final profileController = Get.find<ProfileController>();

  File? frontImage;
  File? backImage;

  final picker = ImagePicker();

  Future pickFront() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => frontImage = File(img.path));
  }

  Future pickBack() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => backImage = File(img.path));
  }

  Future upload() async {
    if (frontImage == null || backImage == null) {
      Get.snackbar("Upload Required", "Upload both Aadhaar sides", colorText: Colors.white);
      return;
    }

    Get.snackbar("Success", "Aadhaar uploaded successfully", colorText: Colors.white);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text("Aadhaar Verification", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF101014),
      ),

      body: Obx(() {
        if (profileController.isUpdating.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [

            title("Front Side"),
            uploadBox(frontImage, profileController.aadhaarFrontImage.value, pickFront),

            const SizedBox(height: 30),

            title("Back Side"),
            uploadBox(backImage, profileController.aadhaarBackImage.value, pickBack),

            const SizedBox(height: 40),
            actionButton("Upload Aadhaar", upload),
          ]),
        );
      }),
    );
  }

  Widget title(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Text(t, style: const TextStyle(color: Colors.white,fontSize:18,fontWeight:FontWeight.w700)),
  );

  Widget uploadBox(File? file, String saved, VoidCallback pick) {
    return GestureDetector(
      onTap: pick,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF252533),
          border: Border.all(color: Colors.white24),
        ),
        child: file != null
            ? Image.file(file, fit: BoxFit.cover)
            : saved.isNotEmpty
            ? Image.file(File(saved), fit: BoxFit.cover)
            : placeholder(),
      ),
    );
  }

  Widget placeholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.upload_file, color: Colors.deepPurpleAccent, size: 46),
      SizedBox(height: 10),
      Text("Tap to upload", style: TextStyle(color: Colors.white70))
    ],
  );

  Widget actionButton(String text, VoidCallback fn) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: fn,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    ),
  );
}
