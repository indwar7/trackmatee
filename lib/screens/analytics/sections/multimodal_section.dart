import 'package:flutter/material.dart';
import '../analytics_models.dart';

class MultimodalSection extends StatelessWidget {
  final List<MultiModalStat> data;
  const MultimodalSection({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(data.isEmpty) return _empty();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Multimodal Journey Stats", style: TextStyle(color:Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        ...data.map((m)=>ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor:kPrimaryPurple.withOpacity(0.12), child: Icon(Icons.swap_calls, color: kPrimaryPurple)), title: Text(m.route, style: TextStyle(color:Colors.white)), subtitle: Text(m.modeBreakdown.entries.map((e)=>"${e.key}:${e.value}").join(", "), style: TextStyle(color: Colors.grey[350]))))
      ]),
    );
  }
  Widget _empty()=>Container(height:120, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No multimodal data", style: TextStyle(color:Colors.grey[300]))));
}
