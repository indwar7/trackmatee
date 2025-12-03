import 'dart:math';
import 'package:intl/intl.dart';
import 'analytics_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockAnalyticsService {
  static final Random _random = Random();
  static final List<String> _districts = [
    'Delhi', 'Gurgaon', 'Noida', 'Greater Noida', 'Neemrana',
    'Meerut', 'Bulandsheher', 'Modinagar', 'Dwarka', 'Saket'
  ];
  static final List<String> _transportModes = ['Bus', 'Car', 'Train', 'Metro', 'Auto', 'Bike'];
  static final List<LatLng> _keralaBounds = [
    const LatLng(8.2914, 76.9489), // South-West
    const LatLng(12.7942, 77.7873), // North-East
  ];

  // Generate random date within last 30 days
  static DateTime _randomDate() {
    final now = DateTime.now();
    return now.subtract(Duration(days: _random.nextInt(30)));
  }

  // Generate random double between min and max
  static double _randomDouble(double min, double max) =>
      _random.nextDouble() * (max - min) + min;

  // Generate random LatLng within Kerala bounds
  static LatLng _randomLatLng() {
    final lat = _randomDouble(_keralaBounds[0].latitude, _keralaBounds[1].latitude);
    final lng = _randomDouble(_keralaBounds[0].longitude, _keralaBounds[1].longitude);
    return LatLng(lat, lng);
  }

  // Mock KPI Data
  static Future<KPIMetrics> fetchKPIs() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return KPIMetrics(
      totalTrips: _random.nextInt(5000) + 1000,
      avgDurationMin: _random.nextDouble() * 60 + 15,
      avgDistanceKm: _random.nextDouble() * 50 + 5,
      totalCarbonKg: _random.nextDouble() * 1000 + 500,
    );
  }

  // Mock Mode Distribution Data
  static Future<List<ModeDatum>> fetchModeDistribution() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transportModes.map((mode) => ModeDatum(
      mode: mode,
      count: _random.nextInt(500) + 100,
    )).toList();
  }

  // Mock District Data
  static Future<List<DistrictBar>> fetchDistrictBars() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _districts.map((district) => DistrictBar(
      district: district,
      total: _random.nextInt(1000) + 200,
    )).toList();
  }

  // Mock Forecast Data
  static Future<Map<String, List<TimePoint>>> fetchForecasts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final demand = List.generate(7, (i) => TimePoint(
      date: now.add(Duration(days: i)),
      value: _random.nextDouble() * 1000 + 500,
    ));
    final carbon = List.generate(7, (i) => TimePoint(
      date: now.add(Duration(days: i)),
      value: _random.nextDouble() * 500 + 200,
    ));
    return {'demand': demand, 'carbon': carbon};
  }

  // Mock Stacked Peak Data
  static Future<List<StackedMode>> fetchStackedPeak() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Peak', 'Off-Peak'].map((period) => StackedMode(
      period: period,
      modeCounts: Map.fromIterables(
        _transportModes,
        List.generate(_transportModes.length, (_) => _random.nextInt(200) + 50),
      ),
    )).toList();
  }

  // Mock Cluster Data
  static Future<List<ClusterPoint>> fetchClusters() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(50, (_) {
      final point = _randomLatLng();
      return ClusterPoint(
        lat: point.latitude,
        lng: point.longitude,
        cluster: _random.nextInt(5),
        count: _random.nextInt(50) + 10,
      );
    });
  }

  // Mock Trip Chains
  static Future<List<TripChain>> fetchTripChains() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final chains = [
      ['Home', 'Work', 'Mall', 'Home'],
      ['Home', 'School', 'Home'],
      ['Home', 'Work', 'Gym', 'Home'],
      ['Home', 'Airport', 'Hotel'],
      ['Home', 'Restaurant', 'Cinema', 'Home'],
    ];
    return chains.map((chain) => TripChain(
      chain: chain,
      count: _random.nextInt(200) + 50,
    )).toList();
  }

  // Mock Anomalies
  static Future<List<AnomalyItem>> fetchAnomalies() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final reasons = [
      'Unusual route deviation',
      'High carbon emission',
      'Long idle time',
      'Multiple cancellations',
      'Speed anomaly',
    ];
    return List.generate(5, (i) => AnomalyItem(
      id: 'anom_${i + 1000}',
      reason: reasons[_random.nextInt(reasons.length)],
      ts: _randomDate(),
    ));
  }

  // Mock Heatmap Data
  static Future<List<ZonePoint>> fetchHeatmap() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(30, (_) {
      final point = _randomLatLng();
      return ZonePoint(
        lat: point.latitude,
        lng: point.longitude,
        count: _random.nextInt(100) + 10,
      );
    });
  }

  // Mock OD Routes
  static Future<List<ODRoute>> fetchTopOD() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final locations = [
      'Kochi', 'Trivandrum', 'Kozhikode', 'Thrissur', 'Kannur',
      'Kollam', 'Alappuzha', 'Palakkad', 'Malappuram', 'Kottayam'
    ];
    return List.generate(5, (_) {
      final origin = locations[_random.nextInt(locations.length)];
      String destination;
      do {
        destination = locations[_random.nextInt(locations.length)];
      } while (destination == origin);

      return ODRoute(
        origin: origin,
        destination: destination,
        count: _random.nextInt(500) + 100,
      );
    });
  }

  // Mock Multimodal Data
  static Future<List<MultiModalStat>> fetchMultimodal() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final routes = [
      'Kochi-Trivandrum',
      'Kozhikode-Kannur',
      'Thrissur-Palakkad',
      'Kollam-Kottayam',
      'Alappuzha-Ernakulam',
    ];
    return routes.map((route) => MultiModalStat(
      route: route,
      modeBreakdown: {
        'Bus': _random.nextInt(100) + 20,
        'Train': _random.nextInt(100) + 20,
        'Metro': _random.nextInt(100) + 20,
        'Auto': _random.nextInt(50) + 10,
      },
    )).toList();
  }

  // Mock Socio-Economic Data
  static Future<Map<String, dynamic>> fetchSocioEconomic() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'income_brackets': {
        '0-10k': _random.nextInt(100) + 50,
        '10k-25k': _random.nextInt(200) + 100,
        '25k-50k': _random.nextInt(150) + 50,
        '50k+': _random.nextInt(100) + 20,
      },
      'accessibility_scores': {
        'City Center': _random.nextDouble() * 2 + 3,  // 3-5
        'Suburbs': _random.nextDouble() * 2 + 2,     // 2-4
        'Rural': _random.nextDouble() * 2 + 1,       // 1-3
      },
    };
  }
}