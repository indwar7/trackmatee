import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_models.dart';

class DistrictBarSection extends StatelessWidget {
  final List<DistrictBar> bars;
  const DistrictBarSection({Key? key, required this.bars}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(bars.isEmpty) return _empty();
    final maxY = bars.map((b)=>b.total.toDouble()).fold(0.0, (a,b)=>a>b?a:b);
    final groups = bars.asMap().entries.map((entry){
      final i = entry.key; final bar = entry.value;
      return BarChartGroupData(x:i, barRods:[BarChartRodData(toY: bar.total.toDouble(), width:14, color:kPrimaryPurple, borderRadius: BorderRadius.circular(6))]);
    }).toList();
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text("Trips by district", style: TextStyle(color:Colors.grey[300],fontWeight:FontWeight.w600)),
          const SizedBox(height:8),
          SizedBox(height:180, child: BarChart(BarChartData(maxY: maxY+10, barGroups: groups, titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,meta){
                final idx = v.toInt().clamp(0,bars.length-1);
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(bars[idx].district, style: TextStyle(color:Colors.grey[350], fontSize:10)));
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles:true))
          ))))
        ])
    );
  }
  Widget _empty()=>Container(height:180, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No district data", style: TextStyle(color:Colors.grey[300]))));
}
