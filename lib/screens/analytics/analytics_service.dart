import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'analytics_models.dart';

class AnalyticsService {
  final String? authToken;
  final String baseUrl;

  AnalyticsService({this.authToken, this.baseUrl = API_BASE});

  Map<String, String> get _headers => {
    if (authToken != null) 'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };

  // Helper method to make GET requests
  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, dynamic>? params}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load data from $endpoint: ${response.statusCode}');
    }
  }

  // KPI Metrics
  Future<KPIMetrics> fetchKPIs({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/summary/', params: params);
    return KPIMetrics.fromJson(data);
  }

  // Mode Distribution
  Future<List<ModeDatum>> fetchModeDistribution({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/modes/', params: params);
    return (data['data'] as List).map((e) => ModeDatum.fromJson(e)).toList();
  }

  // District Bars
  Future<List<DistrictBar>> fetchDistrictBars({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/districts/', params: params);
    return (data['data'] as List).map((e) => DistrictBar.fromJson(e)).toList();
  }

  // Forecasts
  Future<Map<String, List<TimePoint>>> fetchForecasts() async {
    final data = await _get('/analytics/forecasts/');
    return {
      'demand': (data['demand'] as List).map((e) => TimePoint(
        date: DateTime.parse(e['date']),
        value: (e['value'] as num).toDouble(),
      )).toList(),
      'carbon': (data['carbon'] as List).map((e) => TimePoint(
        date: DateTime.parse(e['date']),
        value: (e['value'] as num).toDouble(),
      )).toList(),
    };
  }

  // Stacked Peak
  Future<List<StackedMode>> fetchStackedPeak({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/stacked/', params: params);
    return (data['data'] as List).map((e) => StackedMode.fromJson(e)).toList();
  }

  // Clusters
  Future<List<ClusterPoint>> fetchClusters({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/clusters/', params: params);
    return (data['data'] as List).map((e) => ClusterPoint.fromJson(e)).toList();
  }

  // Trip Chains
  Future<List<TripChain>> fetchTripChains({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/trip_chains/', params: params);
    return (data['data'] as List).map((e) => TripChain.fromJson(e)).toList();
  }

  // Anomalies
  Future<List<AnomalyItem>> fetchAnomalies({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/anomalies/', params: params);
    return (data['data'] as List).map((e) => AnomalyItem.fromJson(e)).toList();
  }

  // Heatmap
  Future<List<ZonePoint>> fetchHeatmap({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/heatmap/', params: params);
    return (data['data'] as List).map((e) => ZonePoint.fromJson(e)).toList();
  }

  // OD Routes
  Future<List<ODRoute>> fetchTopOD({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/od_routes/', params: params);
    return (data['data'] as List).map((e) => ODRoute.fromJson(e)).toList();
  }

  // Multimodal
  Future<List<MultiModalStat>> fetchMultimodal({DateTimeRange? range}) async {
    final params = _buildDateRangeParams(range);
    final data = await _get('/analytics/multimodal/', params: params);
    return (data['data'] as List).map((e) => MultiModalStat.fromJson(e)).toList();
  }

  // Helper to build date range parameters
  Map<String, String> _buildDateRangeParams(DateTimeRange? range) {
    final params = <String, String>{};
    if (range != null) {
      params['start'] = DateFormat('yyyy-MM-dd').format(range.start);
      params['end'] = DateFormat('yyyy-MM-dd').format(range.end);
    }
    return params;
  }
}