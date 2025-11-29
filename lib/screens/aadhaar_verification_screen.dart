// lib/screens/aadhaar_verification_screen.dart

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

  Future<void> pickFrontImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => frontImage = File(file.path));
  }

  Future<void> pickBackImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => backImage = File(file.path));
  }

  Future<void> uploadAadhaar() async {
    if (frontImage == null || backImage == null) {
      Get.snackbar("Error","Upload both front & back images");
      return;
    }
    await profileController.uploadAadhaar(frontImage: frontImage!, backImage: backImage!);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Aadhaar Verification"),
      ),

      body: Obx(() {
        if(profileController.isUpdating.value){
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children:[

            label("Front Side"),
            uploadBox(frontImage, profileController.aadhaarFrontImage.value, pickFrontImage),
            const SizedBox(height:25),

            label("Back Side"),
            uploadBox(backImage, profileController.aadhaarBackImage.value, pickBackImage),

            const SizedBox(height:35),
            button("Upload Aadhaar", uploadAadhaar),
          ]),
        );
      }),
    );
  }

  Widget label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget uploadBox(File? picked, String networkImg, VoidCallback onTap){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,width:double.infinity,
        decoration: BoxDecoration(color: Color(0xFF2A2A3E),borderRadius:BorderRadius.circular(12)),
        child: picked!=null ? Image.file(picked,fit:BoxFit.cover)
            : networkImg.isNotEmpty ? Image.network("http://56.228.42.249$networkImg",fit:BoxFit.cover)
            : placeholder(),
      ),
    );
  }

  Widget placeholder()=>Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children:[
      const Icon(Icons.add_photo_alternate,color: Color(0xFF7C3AED),size:48),
      const SizedBox(height:10),
      const Text("Tap to upload",style:TextStyle(color:Colors.white70))
    ],
  );

  Widget button(String text,VoidCallback tap)=>SizedBox(
    width:double.infinity,height:50,
    child:ElevatedButton(
      onPressed: tap,
      style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF7C3AED)),
      child: Text(text,style:const TextStyle(color:Colors.white,fontSize:16)),
    ),
  );
}
