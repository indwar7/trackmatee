import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF7E60BF);
const Color kBackground = Color(0xFF191919);
const Color kCardGray = Color(0xFF3D3D3D);
const double kRadius = 14.0;
const String HEADER_IMAGE_PATH = '/mnt/data/Screenshot 2025-11-22 at 12.35.17 PM.png';
const String API_BASE = "https://your-backend.com/api/analytics"; // CHANGE
const bool USE_WEBSOCKET = false;
const String WEBSOCKET_URL = "wss://your-backend.com/ws/analytics/";

// KPI model
class KPIMetrics {
  final int totalTrips;
  final double avgDurationMin;
  final double avgDistanceKm;
  final double totalCarbonKg;
  KPIMetrics({required this.totalTrips, required this.avgDurationMin, required this.avgDistanceKm, required this.totalCarbonKg});
  factory KPIMetrics.fromJson(Map<String, dynamic> j) => KPIMetrics(
    totalTrips: j['total_trips'] ?? 0,
    avgDurationMin: (j['avg_duration_min'] ?? 0).toDouble(),
    avgDistanceKm: (j['avg_distance_km'] ?? 0).toDouble(),
    totalCarbonKg: (j['total_carbon_kg'] ?? 0).toDouble(),
  );
}

// Mode distribution
class ModeDatum { final String mode; final int count; ModeDatum({required this.mode, required this.count}); factory ModeDatum.fromJson(Map<String,dynamic> j) => ModeDatum(mode: j['mode'] ?? 'Unknown', count: (j['count'] ?? 0) as int); }

// District bars
class DistrictBar { final String district; final int total; DistrictBar({required this.district, required this.total}); factory DistrictBar.fromJson(Map<String,dynamic> j) => DistrictBar(district: j['district'] ?? '', total: (j['total'] ?? 0) as int); }

// TimePoint for forecasts
class TimePoint { final DateTime date; final double value; TimePoint({required this.date, required this.value}); }

// Stacked peak mode share
class StackedMode { final String period; final Map<String,int> modeCounts; StackedMode({required this.period, required this.modeCounts}); factory StackedMode.fromJson(Map<String,dynamic> j) => StackedMode(period: j['period'] ?? '', modeCounts: Map<String,int>.from(j['modes'] ?? {})); }

// Cluster scatter
class ClusterPoint { final double lat; final double lng; final int cluster; final int count; ClusterPoint({required this.lat, required this.lng, required this.cluster, required this.count}); factory ClusterPoint.fromJson(Map<String,dynamic> j) => ClusterPoint(lat: (j['lat'] as num).toDouble(), lng: (j['lng'] as num).toDouble(), cluster: j['cluster'] ?? 0, count: (j['count'] ?? 0) as int); }

// Trip chain
class TripChain { final List<String> chain; final int count; TripChain({required this.chain, required this.count}); factory TripChain.fromJson(Map<String,dynamic> j) => TripChain(chain: List<String>.from(j['chain'] ?? []), count: (j['count'] ?? 0) as int); }

// Anomaly
class AnomalyItem { 
  final String id; 
  final String reason; 
  final DateTime ts; 
  
  AnomalyItem({required this.id, required this.reason, required this.ts}); 
  
  factory AnomalyItem.fromJson(Map<String,dynamic> j) => AnomalyItem(
    id: j['id'] ?? '', 
    reason: j['reason'] ?? '', 
    ts: DateTime.parse(j['timestamp'])
  ); 
}

// Heatmap zone
class ZonePoint { 
  final double lat; 
  final double lng; 
  final int count; 
  
  ZonePoint({required this.lat, required this.lng, required this.count}); 
  
  factory ZonePoint.fromJson(Map<String,dynamic> j) => ZonePoint(
    lat: (j['lat'] as num).toDouble(), 
    lng: (j['lng'] as num).toDouble(), 
    count: (j['count'] ?? 0) as int
  ); 
}

// O-D routes
class ODRoute { 
  final String origin; 
  final String destination; 
  final int count; 
  
  ODRoute({required this.origin, required this.destination, required this.count}); 
  
  factory ODRoute.fromJson(Map<String,dynamic> j) => ODRoute(
    origin: j['origin'] ?? '', 
    destination: j['destination'] ?? '', 
    count: (j['count'] ?? 0) as int
  ); 
}

// MultiModal (example)
class MultiModalStat { 
  final String route; 
  final Map<String,int> modeBreakdown; 
  
  MultiModalStat({required this.route, required this.modeBreakdown}); 
  
  factory MultiModalStat.fromJson(Map<String,dynamic> j) => MultiModalStat(
    route: j['route'] ?? '', 
    modeBreakdown: Map<String,int>.from(j['mode_breakdown'] ?? {})
  ); 
}
