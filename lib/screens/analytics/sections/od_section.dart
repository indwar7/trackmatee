import 'package:flutter/material.dart';
import '../analytics_models.dart';

class ODSection extends StatelessWidget {
  final List<ODRoute> data;
  const ODSection({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(data.isEmpty) return _empty();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Top OD Routes", style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        ...data.map((r)=>ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: kPrimaryPurple.withOpacity(0.12), child: Icon(Icons.swap_horiz, color: kPrimaryPurple)),
          title: Text("${r.origin} → ${r.destination}", style: TextStyle(color: Colors.white)),
          trailing: Text("${r.count}", style: TextStyle(color: Colors.grey[300])),
        )),
      ]),
    );
  }
  Widget _empty()=>Container(height:120, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No OD data", style: TextStyle(color:Colors.grey[300]))));
}
