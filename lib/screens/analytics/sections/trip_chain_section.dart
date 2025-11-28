import 'package:flutter/material.dart';
import '../analytics_models.dart';

class TripChainSection extends StatelessWidget {
  final List<TripChain> chains;
  const TripChainSection({Key? key, required this.chains}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(chains.isEmpty) return _empty();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Frequent Trip Chains", style: TextStyle(color:Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        ...chains.map((t)=>ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: kPrimaryPurple.withOpacity(0.12), child: Icon(Icons.timeline, color: kPrimaryPurple)),
          title: Text(t.chain.join(" → "), style: TextStyle(color: Colors.white)),
          trailing: Text("${t.count}", style: TextStyle(color: Colors.grey[300])),
        )).toList()
      ]),
    );
  }
  Widget _empty()=>Container(height:120, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No trip chains", style: TextStyle(color:Colors.grey[300]))));
}
