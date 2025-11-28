import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> otp = List.generate(6, (_) => TextEditingController());
  String email = Get.arguments ?? "";
  bool loading = false;

  String get pin => otp.map((e)=>e.text).join();

  Future<void> verifyOTP() async {
    if(pin.length!=6){
      Get.snackbar("Invalid OTP","Enter 6 digits",backgroundColor:Colors.red,colorText:Colors.white);
      return;
    }

    setState(()=>loading=true);

    final res = await http.post(
      Uri.parse("http://56.228.42.249/api/auth/verify/"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({"email":email,"otp":pin}),
    );

    setState(()=>loading=false);

    if(res.statusCode==200){
      Get.snackbar("Verified","Email verified",backgroundColor:Colors.green,colorText:Colors.white);
      Get.offAllNamed('/login');
    }else{
      Get.snackbar("Failed","OTP incorrect",backgroundColor:Colors.red,colorText:Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF1A1A2E),
      appBar: AppBar(backgroundColor:Colors.transparent,elevation:0,title:const Text("Verify OTP",style:TextStyle(color:Colors.white))),
      body:Padding(
        padding:const EdgeInsets.all(24),
        child:Column(children:[
          const SizedBox(height:40),

          Row(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children:List.generate(6,(i)=>SizedBox(
                width:48,
                child:TextField(
                  controller:otp[i],
                  maxLength:1,
                  style:const TextStyle(color:Colors.white,fontSize:20),
                  textAlign:TextAlign.center,
                  keyboardType:TextInputType.number,
                  decoration:const InputDecoration(counterText:"",filled:true,fillColor:Color(0xFF16213E)),
                  onChanged:(_){if(_.isNotEmpty&&i<5)FocusScope.of(context).nextFocus();},
                ),
              ))),

          const Spacer(),

          SizedBox(
              width:double.infinity,height:56,
              child:ElevatedButton(
                onPressed:loading?null:verifyOTP,
                style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF8B5CF6)),
                child:loading?const CircularProgressIndicator(color:Colors.white)
                    :const Text("Verify",style:TextStyle(fontSize:18)),
              ))
        ]),
      ),
    );
  }
}
