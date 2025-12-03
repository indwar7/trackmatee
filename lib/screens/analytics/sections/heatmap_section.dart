import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../analytics_models.dart';

class HeatmapSection extends StatefulWidget {
  final List<ZonePoint> points;
  const HeatmapSection({Key? key, required this.points}) : super(key: key);
  @override
  State<HeatmapSection> createState() => _HeatmapSectionState();
}

class _HeatmapSectionState extends State<HeatmapSection> {
  Set<Circle> _circles = {};
  GoogleMapController? _mapController;
  @override
  void initState() {
    super.initState();
    _buildCircles();
  }
  void _buildCircles(){
    final pts = widget.points;
    if(pts.isEmpty){ setState(()=>_circles={}); return;}
    int maxc = pts.map((p)=>p.count).fold(0, (a,b)=>a>b?a:b);
    if(maxc==0) maxc=1;
    final Set<Circle> circles = {};
    for(final p in pts){
      final double ratio = p.count / maxc;
      final double radius = 1500 + ratio * 9000;
      final col = Color.fromARGB(255, (200*ratio+55).toInt().clamp(0,255), (200*(1-ratio)+20).toInt().clamp(0,255), 60);
      circles.add(Circle(circleId: CircleId("${p.lat}_${p.lng}"), center: LatLng(p.lat,p.lng), radius: radius, fillColor: col.withOpacity(0.45), strokeColor: col.withOpacity(0.8)));
    }
    setState(()=>_circles = circles);
  }
  @override
  Widget build(BuildContext c){
    return Container(
      height:260,
      decoration: BoxDecoration(color:kCardGray,borderRadius: BorderRadius.circular(kRadius)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.8505, 76.2711), zoom: 7.5),
          circles: _circles,
          onMapCreated: (c) => _mapController = c,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}
