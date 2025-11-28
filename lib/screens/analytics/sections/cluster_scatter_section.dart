import 'package:flutter/material.dart';
import '../analytics_models.dart';

class ClusterScatterSection extends StatelessWidget {
  final List<ClusterPoint> points;
  const ClusterScatterSection({Key? key, required this.points}) : super(key: key);
  @override
  Widget build(BuildContext c){
    if(points.isEmpty) return _empty();
    // We will render a simple grid scatter using normalized coordinates for frontend preview.
    final lats = points.map((p)=>p.lat).toList();
    final lngs = points.map((p)=>p.lng).toList();
    final minLat = lats.reduce((a,b)=>a<b?a:b), maxLat = lats.reduce((a,b)=>a>b?a:b);
    final minLng = lngs.reduce((a,b)=>a<b?a:b), maxLng = lngs.reduce((a,b)=>a>b?a:b);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text("Trip Clusters (visual)", style: TextStyle(color:Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        SizedBox(height:180, child: LayoutBuilder(builder:(context, size){
          return Stack(children: points.map((p){
            final nx = (p.lng - minLng) / (maxLng - minLng + 1e-9);
            final ny = 1 - (p.lat - minLat) / (maxLat - minLat + 1e-9);
            final left = nx * (size.maxWidth - 16);
            final top = ny * (size.maxHeight - 16);
            return Positioned(left: left, top: top, child: _dotForCluster(p.cluster, p.count));
          }).toList());
        })),
      ]),
    );
  }
  Widget _dotForCluster(int c, int count) {
    final colors = [Colors.purpleAccent, Colors.orangeAccent, Colors.lightGreenAccent, Colors.blueAccent, Colors.tealAccent];
    final double size = (6 + (count/10)).clamp(6, 24).toDouble();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[c % colors.length],
        shape: BoxShape.circle
      ),
    );
  }
  Widget _empty()=>Container(height:180, decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)), child: Center(child: Text("No cluster data", style: TextStyle(color:Colors.grey[300]))));
}
