import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_models.dart';

class ModePieSection extends StatelessWidget {
  final List<ModeDatum> data;
  const ModePieSection({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(data.isEmpty) return _empty();
    final total = data.fold<int>(0,(s,e)=>s+e.count);
    final palette = [kPrimaryPurple, Colors.deepOrangeAccent, Colors.greenAccent, Colors.blueAccent, Colors.tealAccent];
    final sections = data.asMap().entries.map((entry){
      final m = entry.value;
      final idx = entry.key;
      final pct = total==0?0:(m.count/total*100);
      return PieChartSectionData(value: m.count.toDouble(), title: "${pct.toStringAsFixed(0)}%", color: palette[idx%palette.length], radius:48, titleStyle: TextStyle(color:Colors.white,fontWeight:FontWeight.bold));
    }).toList();
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text("Mode distribution", style: TextStyle(color: Colors.grey[300],fontWeight: FontWeight.w600)),
          const SizedBox(height:8),
          SizedBox(height:140, child: PieChart(PieChartData(sections: sections, centerSpaceRadius:26))),
          const SizedBox(height:8),
          Wrap(spacing:8, children: data.map((m)=>Chip(label: Text("${m.mode} (${m.count})"), backgroundColor: Colors.black26)).toList())
        ])
    );
  }
  Widget _empty()=>Container(height:140, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No data", style: TextStyle(color:Colors.grey[300]))));
}
