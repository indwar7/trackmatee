import 'package:flutter/material.dart';
import '../analytics_models.dart';
import 'package:intl/intl.dart';

class AnomalySection extends StatelessWidget {
  final List<AnomalyItem> anomalies;
  const AnomalySection({Key? key, required this.anomalies}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(anomalies.isEmpty) return _empty();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Detected Anomalies", style: TextStyle(color:Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        ...anomalies.map((a)=>ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.12), child: Icon(Icons.warning_amber_outlined, color: Colors.redAccent)),
          title: Text(a.reason, style: TextStyle(color:Colors.white)),
          subtitle: Text(DateFormat.yMMMd().add_jm().format(a.ts), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        )).toList()
      ]),
    );
  }
  Widget _empty()=>Container(height:120, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No anomalies detected", style: TextStyle(color:Colors.grey[300]))));
}
