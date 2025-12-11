// lib/models/stats_model.dart

// ---------------------------------------------------------------------------
// DAILY SCORE RESPONSE
// ---------------------------------------------------------------------------

class DailyScoreResponse {
  final int score;
  final String date;
  final double distanceTravelled;
  final double co2Emissions;
  final double fuelCost;
  final int tripsCount;

  DailyScoreResponse({
    required this.score,
    required this.date,
    required this.distanceTravelled,
    required this.co2Emissions,
    required this.fuelCost,
    required this.tripsCount,
  });

  factory DailyScoreResponse.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return DailyScoreResponse(
      score: json["score"] ?? 0,
      date: json["date"] ?? "",
      distanceTravelled: _toDouble(json["distance_travelled"]),
      co2Emissions: _toDouble(json["co2_emissions"]),
      fuelCost: _toDouble(json["fuel_cost"]),
      tripsCount: json["trips_count"] ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// CALENDAR STATS RESPONSE
// ---------------------------------------------------------------------------

class CalendarStatsResponse {
  final String month;
  final int year;
  final List<CalendarDayData> days;

  CalendarStatsResponse({
    required this.month,
    required this.year,
    required this.days,
  });

  factory CalendarStatsResponse.fromJson(Map<String, dynamic> json) {
    return CalendarStatsResponse(
      month: json["month"] ?? "",
      year: json["year"] ?? 0,
      days: (json["days"] as List<dynamic>? ?? [])
          .map((e) => CalendarDayData.fromJson(e))
          .toList(),
    );
  }
}

class CalendarDayData {
  final String date;
  final int score;
  final bool hasTrips;
  final int tripsCount;

  CalendarDayData({
    required this.date,
    required this.score,
    required this.hasTrips,
    required this.tripsCount,
  });

  factory CalendarDayData.fromJson(Map<String, dynamic> json) {
    return CalendarDayData(
      date: json["date"] ?? "",
      score: json["score"] ?? 0,
      hasTrips: json["has_trips"] ?? false,
      tripsCount: json["trips_count"] ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// MONTHLY CHART RESPONSE
// ---------------------------------------------------------------------------

class MonthlyChartResponse {
  final List<ChartPoint> distance;
  final List<ChartPoint> co2Emissions;
  final List<ChartPoint> fuelCost;

  MonthlyChartResponse({
    required this.distance,
    required this.co2Emissions,
    required this.fuelCost,
  });

  factory MonthlyChartResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyChartResponse(
      distance: (json["distance"] as List<dynamic>? ?? [])
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
      co2Emissions: (json["co2_emissions"] as List<dynamic>? ?? [])
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
      fuelCost: (json["fuel_cost"] as List<dynamic>? ?? [])
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
    );
  }
}

class ChartPoint {
  final String date;
  final double value;

  ChartPoint({required this.date, required this.value});

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return ChartPoint(
      date: json["date"] ?? "",
      value: _toDouble(json["value"]),
    );
  }
}
