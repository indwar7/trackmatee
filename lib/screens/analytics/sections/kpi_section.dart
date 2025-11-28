import 'package:flutter/material.dart';
import '../analytics_models.dart';

class KPISection extends StatelessWidget {
  final KPIMetrics data;
  const KPISection({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext c) {
    return Column(children: [
      _card("Total Trips", "${data.totalTrips}", Icons.travel_explore),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _card("Avg Duration", "${data.avgDurationMin.toStringAsFixed(1)} min", Icons.timer)),
        const SizedBox(width: 10),
        Expanded(child: _card("Avg Distance", "${data.avgDistanceKm.toStringAsFixed(1)} km", Icons.route)),
      ]),
      const SizedBox(height: 10),
      _card("Total Carbon", "${data.totalCarbonKg.toStringAsFixed(1)} kg", Icons.eco),
    ]);
  }
  Widget _card(String title,String val,IconData icon)=>Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: kCardGray,borderRadius: BorderRadius.circular(kRadius)),
    child: Row(children:[
      CircleAvatar(backgroundColor: kPrimaryPurple.withOpacity(0.12),child: Icon(icon,color:kPrimaryPurple)),
      const SizedBox(width:12),
      Expanded(child: Text(title, style: TextStyle(color: Colors.grey[300]))),
      Text(val, style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)),
    ]),
  );
}
