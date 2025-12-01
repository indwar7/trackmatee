import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlanATripScreen extends StatefulWidget {
  const PlanATripScreen({super.key});

  @override
  State<PlanATripScreen> createState() => _PlanATripScreenState();
}

class _PlanATripScreenState extends State<PlanATripScreen> {
  final TextEditingController startC = TextEditingController();
  final TextEditingController destC = TextEditingController();

  List<String> locations = [
    "Delhi NCR", "New Delhi", "Dehradun", "Dwarka", "Dewas", "Gurgaon", "Faridabad",
  ];

  bool showStartList = false;
  bool showDestList = false;
  bool setOnMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,size: 26),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Choose start point",
          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

          // START INPUT BOX ---------------------------------------------------------
          GestureDetector(
            onTap: () => setState(() => showStartList = !showStartList),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: const [
                    Icon(Icons.radio_button_checked,color: Colors.deepPurple,size: 22),
                    SizedBox(width: 12),
                    Text("Start",style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w500)),
                  ]),
                  Text(startC.text.isEmpty ? "Pickup Location" : startC.text,
                      style: const TextStyle(color: Colors.white70,fontSize: 14))
                ],
              ),
            ),
          ),

          if(showStartList)
            _buildDropBox(select: (v){
              setState((){ startC.text = v; showStartList=false;});
            }),

          const SizedBox(height: 20),

          // DESTINATION INPUT -------------------------------------------------------
          GestureDetector(
            onTap: () => setState(() => showDestList = !showDestList),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple,width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: const [
                    Icon(Icons.radio_button_unchecked,color: Colors.deepPurple,size: 22),
                    SizedBox(width: 12),
                    Text("Destination",style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w500)),
                  ]),
                  Text(destC.text.isEmpty?"Drop Location":destC.text,
                      style: const TextStyle(color: Colors.white70,fontSize: 14)),
                ],
              ),
            ),
          ),

          if(showDestList)
            _buildDropBox(select:(v){
              setState((){ destC.text=v; showDestList=false;});
            }),

          const SizedBox(height: 15),

          // SET ON MAP OPTION ------------------------------------------------------
          Row(
            children: [
              Checkbox(
                value: setOnMap,
                activeColor: Colors.deepPurple,
                onChanged:(v)=>setState(()=>setOnMap=v!),
              ),
              const Text("Set on map",style: TextStyle(color: Colors.white70,fontSize: 15)),
            ],
          ),

          const Spacer(),

          // DONE BUTTON ------------------------------------------------------------
          SizedBox(
              width: double.infinity,height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: (){
                  if(startC.text.isEmpty || destC.text.isEmpty){
                    Get.snackbar("Missing info","Select start & drop location",
                        snackPosition:SnackPosition.BOTTOM,colorText:Colors.white);
                  } else{
                    Get.snackbar("Trip Saved",
                        "From: ${startC.text} → To: ${destC.text}",
                        snackPosition:SnackPosition.BOTTOM,backgroundColor:Colors.deepPurple,colorText:Colors.white);
                  }
                },
                child: const Text("Done",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
              )
          ),

          const SizedBox(height: 10)
        ]),
      ),
    );
  }

  // DROPDOWN UI BOX --------------------------------------------------------------
  Widget _buildDropBox({required Function(String) select}){
    return Container(
      margin: const EdgeInsets.only(top:10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: locations.map((place)=> GestureDetector(
          onTap: ()=> select(place),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical:10),
            child: Text(place,style: const TextStyle(color:Colors.white,fontSize:15)),
          ),
        )).toList(),
      ),
    );
  }
}
