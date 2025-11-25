import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_models.dart';

class StackedPeakSection extends StatelessWidget {
  final List<StackedMode> data;
  const StackedPeakSection({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(data.isEmpty) return _empty();
    final keys = <String>{};
    for(var s in data) keys.addAll(s.modeCounts.keys);
    final modeList = keys.toList();
    final groups = data.asMap().entries.map((entry){
      final i = entry.key; final s = entry.value;
      double x = i.toDouble();
      double running = 0;
      final rods = <BarChartRodStackItem>[];
      for(var m in modeList){
        final val = (s.modeCounts[m] ?? 0).toDouble();
        rods.add(BarChartRodStackItem(running, running + val, _colorForMode(m)));
        running += val;
      }
      return BarChartGroupData(x:i, barRods:[BarChartRodData(toY: running, rodStackItems: rods, width: 18, borderRadius: BorderRadius.circular(6))]);
    }).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Peak vs Off-peak Mode Share", style: TextStyle(color:Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        SizedBox(height:180, child: BarChart(BarChartData(barGroups: groups, titlesData: FlTitlesData(show:true)))),
      ]),
    );
  }
  Color _colorForMode(String m){
    final key = m.toLowerCase();
    if(key.contains("bus")) return Colors.blueAccent;
    if(key.contains("car")) return Colors.orangeAccent;
    if(key.contains("walk")) return Colors.greenAccent;
    return Colors.purpleAccent;
  }
  Widget _empty()=>Container(height:160, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No data", style: TextStyle(color:Colors.grey[300]))));
}
