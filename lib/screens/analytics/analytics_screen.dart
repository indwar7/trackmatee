import 'package:flutter/material.dart';
import 'analytics_models.dart';
import 'mock_analytics_service.dart';
import 'sections/kpi_section.dart';
import 'sections/mode_pie_section.dart';
import 'sections/district_bar_section.dart';
import 'sections/forecast_section.dart';
import 'sections/stacked_peak_section.dart';
import 'sections/cluster_scatter_section.dart';
import 'sections/trip_chain_section.dart';
import 'sections/anomaly_section.dart';
import 'sections/heatmap_section.dart';
import 'sections/od_section.dart';
import 'sections/socio_economic_section.dart';
import 'sections/multimodal_section.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<Map<String, dynamic>> _analyticsData;

  @override
  void initState() {
    super.initState();
    _analyticsData = _fetchAllAnalytics();
  }

  Future<Map<String, dynamic>> _fetchAllAnalytics() async {
    return {
      'kpis': await MockAnalyticsService.fetchKPIs(),
      'modes': await MockAnalyticsService.fetchModeDistribution(),
      'districts': await MockAnalyticsService.fetchDistrictBars(),
      'forecasts': await MockAnalyticsService.fetchForecasts(),
      'stacked': await MockAnalyticsService.fetchStackedPeak(),
      'clusters': await MockAnalyticsService.fetchClusters(),
      'chains': await MockAnalyticsService.fetchTripChains(),
      'anomalies': await MockAnalyticsService.fetchAnomalies(),
      'heatmap': await MockAnalyticsService.fetchHeatmap(),
      'ods': await MockAnalyticsService.fetchTopOD(),
      'multimodal': await MockAnalyticsService.fetchMultimodal(),
      'socio': await MockAnalyticsService.fetchSocioEconomic(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Analytics Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kBackground,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryPurple)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!;
          final kpis = data['kpis'] as KPIMetrics;
          final modes = data['modes'] as List<ModeDatum>;
          final districts = data['districts'] as List<DistrictBar>;
          final forecasts = data['forecasts'] as Map<String, List<TimePoint>>;
          final stacked = data['stacked'] as List<StackedMode>;
          final clusters = data['clusters'] as List<ClusterPoint>;
          final chains = data['chains'] as List<TripChain>;
          final anomalies = data['anomalies'] as List<AnomalyItem>;
          final heatmap = data['heatmap'] as List<ZonePoint>;
          final ods = data['ods'] as List<ODRoute>;
          final multimodal = data['multimodal'] as List<MultiModalStat>;
          final socio = data['socio'] as Map<String, dynamic>;

          return RefreshIndicator(
            onRefresh: () {
              setState(() {
                _analyticsData = _fetchAllAnalytics();
              });
              return _analyticsData;
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                KPISection(data: kpis),
                const SizedBox(height: 20),
                ModePieSection(data: modes),
                const SizedBox(height: 20),
                DistrictBarSection(bars: districts),
                const SizedBox(height: 20),
                ForecastSection(demand: forecasts['demand']!, carbon: forecasts['carbon']!),
                const SizedBox(height: 20),
                StackedPeakSection(data: stacked),
                const SizedBox(height: 20),
                ClusterScatterSection(points: clusters),
                const SizedBox(height: 20),
                TripChainSection(chains: chains),
                const SizedBox(height: 20),
                AnomalySection(anomalies: anomalies),
                const SizedBox(height: 20),
                HeatmapSection(points: heatmap),
                const SizedBox(height: 20),
                ODSection(data: ods),
                const SizedBox(height: 20),
                SocioEconomicSection(payload: socio),
                const SizedBox(height: 20),
                MultimodalSection(data: multimodal),
              ],
            ),
          );
        },
      ),
    );
  }
}
