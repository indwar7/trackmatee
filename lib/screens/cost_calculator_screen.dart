import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cost_calculator_controller.dart';

class CostCalculatorScreen extends StatelessWidget {
  const CostCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CostCalculatorController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Cost calculator',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          return controller.isCalculated.value
              ? _buildResultPage(controller)
              : _buildInputPage(controller);
        }),
      ),
    );
  }

  // ------------------------------------------------------------ INPUT FORM UI
  Widget _buildInputPage(CostCalculatorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the following',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildInputField(controller.startLocationController, 'Start Location', Icons.location_on),
          const SizedBox(height: 16),

          _buildInputField(controller.endLocationController, 'End Location', Icons.location_on),
          const SizedBox(height: 16),

          _buildInputField(controller.distanceController, 'Calculated distance', Icons.straighten,
              keyboardType: TextInputType.number, suffix: 'km'),
          const SizedBox(height: 16),

          _buildSelectableField(label: "Mode of Travel", value: controller.modeOfTravel.value,
              onTap: () => _showModeOfTravelSheet(controller)),
          const SizedBox(height: 16),

          _buildInputField(controller.companionsController, 'Number of companions', Icons.people,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),

          _buildInputField(controller.fuelPriceController, 'Fuel price', Icons.local_gas_station,
              keyboardType: TextInputType.number, prefix: '₹'),
          const SizedBox(height: 16),

          _buildSelectableField(label: "Fuel type", value: controller.fuelType.value,
              onTap: () => _showFuelTypeSheet(controller)),
          const SizedBox(height: 16),

          _buildInputField(controller.averageController,
              'Average of the vehicle\n(Only for car users)', Icons.speed,
              keyboardType: TextInputType.number, suffix: 'km/l'),
          const SizedBox(height: 16),

          _buildInputField(controller.parkingCostController, 'Parking cost', Icons.local_parking,
              keyboardType: TextInputType.number, prefix: '₹'),
          const SizedBox(height: 16),

          _buildInputField(controller.tollCostController, 'Toll cost', Icons.toll,
              keyboardType: TextInputType.number, prefix: '₹'),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.calculateCost(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ RESULT PAGE
  Widget _buildResultPage(CostCalculatorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const Text('Trip cost', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildCostBar('Car', controller.carCost.value, 150, controller.modeOfTravel.value == 'Car'),
            _buildCostBar('Bike', controller.bikeCost.value, 120, controller.modeOfTravel.value == 'Bike'),
            _buildCostBar('Airplane', controller.airplaneCost.value, 180, controller.modeOfTravel.value == 'Airplane'),
            _buildCostBar('Train', controller.trainCost.value, 140, controller.modeOfTravel.value == 'Train'),
          ],
        ),

        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Trip Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDashedLine(),
            const SizedBox(height: 16),

            _buildDetailRow('Mode of travel', controller.modeOfTravel.value),
            _buildDetailRow('Companions', controller.companionsController.text),
            _buildDetailRow('Fuel price', "₹${controller.fuelPriceController.text}"),
            _buildDetailRow('Fuel type', controller.fuelType.value),
            _buildDetailRow('Vehicle average', "${controller.averageController.text} km/l"),
            _buildDetailRow('Parking cost', "₹${controller.parkingCostController.text}"),
            _buildDetailRow('Toll cost', "₹${controller.tollCostController.text}"),
            _buildDetailRow('CO2 emitted', "${controller.co2Emission.toStringAsFixed(2)} kg", isHighlight:true),
            _buildDetailRow('Per person cost', "₹${controller.perPersonCost.value.toStringAsFixed(0)}",
                isHighlight:true, isBold:true),

            const SizedBox(height: 16),
            _buildDashedLine(),
            const SizedBox(height: 16),

            const Text('Cost Comparison', style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const SizedBox(height:16),

            _buildComparisonRow('Car', controller.carCost.value),
            _buildComparisonRow('Bike', controller.bikeCost.value),
            _buildComparisonRow('Airplane', controller.airplaneCost.value),
            _buildComparisonRow('Train', controller.trainCost.value),
            _buildComparisonRow('Hired cab', controller.cabCost.value),
          ]),
        ),

        const SizedBox(height:24),

        SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: () => Get.snackbar("Download","Trip summary downloaded",
                backgroundColor: const Color(0xFF7C3AED), colorText: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor:const Color(0xFF7C3AED),
                shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
            child: const Text('Download Image', style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
          ),
        ),

        const SizedBox(height:12),

        SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: () => controller.reset(),
            style: ElevatedButton.styleFrom(backgroundColor:const Color(0xFF7C3AED),
                shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
            child: const Text('Done', style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
          ),
        ),

        const SizedBox(height:32),
      ]),
    );
  }

  // ------------------------------------------------------------ INPUT FIELD
  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType,String? prefix,String? suffix}) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal:20,vertical:8),
      decoration: BoxDecoration(border:Border.all(color:Colors.white30),borderRadius:BorderRadius.circular(12)),
      child: Row(children:[
        Icon(icon,color:Colors.white54,size:20), const SizedBox(width:12),
        Expanded(
          child: TextField(
            controller:controller, keyboardType:keyboardType,
            style: const TextStyle(color:Colors.white,fontSize:16),
            decoration:InputDecoration(
              labelText:label,labelStyle:const TextStyle(color:Colors.white54,fontSize:14),
              border:InputBorder.none,prefixText:prefix,suffixText:suffix,
              prefixStyle:const TextStyle(color:Colors.white),suffixStyle:const TextStyle(color:Colors.white54),
            ),
          ),
        )
      ]),
    );
  }

  // ------------------------------------------------------------ SELECT FIELDS
  Widget _buildSelectableField({required String label,required String value,required VoidCallback onTap}) {
    return GestureDetector(
      onTap:onTap,
      child:Container(
        padding:const EdgeInsets.symmetric(horizontal:20,vertical:20),
        decoration:BoxDecoration(border:Border.all(color:Colors.white30),borderRadius:BorderRadius.circular(12)),
        child:Row(children:[
          Icon(Icons.arrow_drop_down,color:Colors.white54,size:20),const SizedBox(width:12),
          Expanded(
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(label,style:const TextStyle(color:Colors.white54,fontSize:14)),
              if(value.isNotEmpty) Text(value,style:const TextStyle(color:Colors.white,fontSize:16))
            ]),
          ),
        ]),
      ),
    );
  }

  // ------------------------------------------------------------ MODE SELECT
  void _showModeOfTravelSheet(CostCalculatorController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children: [
          const Text('Select Mode of Travel',
              style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),
          const SizedBox(height:24),

          _buildModeOption('Car', controller),
          _buildModeOption('Bike', controller),
          _buildModeOption('Bus', controller),
          _buildModeOption('Airplane', controller),
          _buildModeOption('Train', controller),
          _buildModeOption('Bi-cycle', controller),
          _buildModeOption('Walk', controller),
          const SizedBox(height:16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ()=>Get.back(),
              style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF7C3AED),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              child:const Text('Done',style:TextStyle(color:Colors.white)),
            ),
          )
        ]),
      ),
    );
  }

  void _showFuelTypeSheet(CostCalculatorController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children: [
          const Text('Select Fuel Type',
              style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),
          const SizedBox(height:24),

          _buildFuelOption('Petrol', controller),
          _buildFuelOption('Diesel', controller),
          _buildFuelOption('Electric', controller),
          const SizedBox(height:16),

          SizedBox(
            width:double.infinity,
            child:ElevatedButton(
              onPressed:()=>Get.back(),
              style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF7C3AED),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              child:const Text('Done',style:TextStyle(color:Colors.white)),
            ),
          )
        ]),
      ),
    );
  }

  // ------------------------------------------------------------ SELECTORS
  Widget _buildModeOption(String mode, CostCalculatorController controller) {
    return Obx(() => CheckboxListTile(
      title:Text(mode,style:const TextStyle(color:Colors.white)),
      value:controller.modeOfTravel.value==mode,
      onChanged:(v){if(v==true) controller.modeOfTravel.value=mode;},
      activeColor:const Color(0xFF7C3AED), checkColor:Colors.white,
    ));
  }

  Widget _buildFuelOption(String fuel, CostCalculatorController controller) {
    return Obx(() => CheckboxListTile(
      title:Text(fuel,style:const TextStyle(color:Colors.white)),
      value:controller.fuelType.value==fuel,
      onChanged:(v){if(v==true) controller.fuelType.value=fuel;},
      activeColor:const Color(0xFF7C3AED), checkColor:Colors.white,
    ));
  }

  // ------------------------------------------------------------ GRAPH BAR
  Widget _buildCostBar(String label,double cost,double height,bool isSelected){
    return Column(children:[
      Container(
        width:70, height:height,
        decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(8),
          gradient:LinearGradient(
            colors:[Colors.pink.withOpacity(0.6),const Color(0xFF7C3AED).withOpacity(0.8)],
            begin:Alignment.topCenter,end:Alignment.bottomCenter,
          ),
          border:isSelected?Border.all(color:Colors.white,width:2):null,
        ),
        child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          const Text('Per-\nperson',textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:10)),
          const SizedBox(height:8),
          Text('₹${cost.toStringAsFixed(0)}\ntotal',
              textAlign:TextAlign.center,
              style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.bold)),
        ]),
      ),
      const SizedBox(height:8),
      Text(label,style:const TextStyle(color:Colors.white,fontSize:14)),
    ]);
  }

  // ------------------------------------------------------------ DETAILS + COMPARE
  Widget _buildComparisonRow(String m,double c){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:6),
      child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        Text("$m",style:const TextStyle(fontSize:15,color:Colors.black)),
        Text("₹${c.toStringAsFixed(0)}",
            style:const TextStyle(fontSize:15,fontWeight:FontWeight.w600,color:Colors.black)),
      ]),
    );
  }

  Widget _buildDetailRow(String label,String value,{bool isHighlight=false,bool isBold=false}){
    return Padding(
      padding:const EdgeInsets.symmetric(vertical:5),
      child:Row(children:[
        Expanded(
          child:Text("$label:",
              style:TextStyle(fontSize:15,color:isHighlight?Colors.black:Colors.black87,
                  fontWeight:isBold?FontWeight.bold:FontWeight.normal)),
        ),
        Text(value,style:TextStyle(fontSize:15,fontWeight:isBold?FontWeight.bold:FontWeight.w600,
            color:isHighlight?Colors.black:Colors.black87)),
      ]),
    );
  }

  Widget _buildDashedLine(){
    return Row(children: List.generate(30,(i)=>Expanded(
        child:Container(margin:const EdgeInsets.symmetric(horizontal:2),
            height:2,color:Colors.black))));
  }
}
