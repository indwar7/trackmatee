// lib/models/stats_models.dart

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
    return DailyScoreResponse(
      score: json["score"] ?? 0,
      date: json["date"] ?? "",
      distanceTravelled:
      (json["distance_travelled"] ?? 0.0).toDouble(),
      co2Emissions:
      (json["co2_emissions"] ?? 0.0).toDouble(),
      fuelCost:
      (json["fuel_cost"] ?? 0.0).toDouble(),
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
      days: (json["days"] as List<dynamic>)
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
      distance: (json["distance"] as List<dynamic>)
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
      co2Emissions: (json["co2_emissions"] as List<dynamic>)
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
      fuelCost: (json["fuel_cost"] as List<dynamic>)
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
    );
  }
}

class ChartPoint {
  final String date;
  final double value;

  ChartPoint({
    required this.date,
    required this.value,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      date: json["date"] ?? "",
      value: (json["value"] ?? 0.0).toDouble(),
    );
  }
}
