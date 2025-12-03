import 'package:flutter/material.dart';
import '../analytics_models.dart';

class SocioEconomicSection extends StatelessWidget {
  final Map<String, dynamic> payload; // e.g., {"income_brackets": {...}, "accessibility_scores": {...}}
  const SocioEconomicSection({Key? key, required this.payload}) : super(key: key);
  @override
  Widget build(BuildContext c){
    // This is a flexible placeholder: render a short summary and a small table
    final income = Map<String,int>.from(payload['income_brackets'] ?? {});
    final access = Map<String,double>.from(payload['accessibility_scores'] ?? {});
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Socio-economic insights", style: TextStyle(color:Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        Text("Income distribution (sampled trips):", style: TextStyle(color: Colors.grey[350])),
        const SizedBox(height:6),
        Wrap(spacing:8, children: income.entries.map((e)=>Chip(label: Text("${e.key}: ${e.value}"), backgroundColor: Colors.black26)).toList()),
        const SizedBox(height:8),
        Text("Accessibility scores:", style: TextStyle(color: Colors.grey[350])),
        const SizedBox(height:6),
        ...access.entries.map((e)=>ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.location_on,color:kPrimaryPurple), title: Text(e.key, style: TextStyle(color:Colors.white)), trailing: Text(e.value.toStringAsFixed(2), style: TextStyle(color:Colors.grey[300])))),
      ]),
    );
  }
}
