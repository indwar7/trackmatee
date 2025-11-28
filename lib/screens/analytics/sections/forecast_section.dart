import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_models.dart';
import 'package:intl/intl.dart';

class ForecastSection extends StatelessWidget {
  final List<TimePoint> demand;
  final List<TimePoint> carbon;
  const ForecastSection({Key? key, required this.demand, required this.carbon}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(demand.isEmpty && carbon.isEmpty) return _empty();
    final dates = demand.isNotEmpty? demand.map((e)=>DateFormat.MMMd().format(e.date)).toList() : carbon.map((e)=>DateFormat.MMMd().format(e.date)).toList();
    final spotsD = demand.asMap().entries.map((e)=>FlSpot(e.key.toDouble(), e.value.value)).toList();
    final spotsC = carbon.asMap().entries.map((e)=>FlSpot(e.key.toDouble(), e.value.value)).toList();
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kCardGray, borderRadius: BorderRadius.circular(kRadius)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text("Demand & Carbon Forecast", style: TextStyle(color:Colors.grey[300], fontWeight:FontWeight.w600)),
          const SizedBox(height:8),
          SizedBox(height:160, child: LineChart(LineChartData(
              gridData: FlGridData(show:true),
              titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles:true, getTitlesWidget: (v,meta)=>SideTitleWidget(axisSide: meta.axisSide, child: Text(dates[v.toInt().clamp(0, dates.length-1)], style: TextStyle(color:Colors.grey[350], fontSize:10)))))),
              lineBarsData: [
                if(spotsD.isNotEmpty) LineChartBarData(spots: spotsD, isCurved:true, color: kPrimaryPurple, barWidth:3, dotData: FlDotData(show:false)),
                if(spotsC.isNotEmpty) LineChartBarData(spots: spotsC, isCurved:true, color: Colors.orangeAccent, barWidth:3, dotData: FlDotData(show:false))
              ]
          ))),
          const SizedBox(height:6),
          Row(children:[_legend(kPrimaryPurple,"Demand"), const SizedBox(width:10), _legend(Colors.orangeAccent,"Carbon")])
        ])
    );
  }
  Widget _legend(Color c, String t) => Row(children:[Container(width:10,height:6,color:c), const SizedBox(width:6), Text(t, style: TextStyle(color:Colors.grey[300]))]);
  Widget _empty()=>Container(height:160, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No forecast data", style: TextStyle(color:Colors.grey[300]))));
}
