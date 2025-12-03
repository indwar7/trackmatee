import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:trackmate_app/models/stats_model.dart';

class StatsApiService {
  static const String baseUrl = "http://56.228.42.249/api/trips/stats";

  String _authToken = "";

  /// Set auth token from AuthService
  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": "Token $_authToken",
  };

  // ---------------------------------------------------------------------------
  // GET DAILY SCORE
  // ---------------------------------------------------------------------------
  Future<DailyScoreResponse> getDailyScore({String? date}) async {
    String url = "$baseUrl/daily-score/";

    if (date != null && date.isNotEmpty) {
      url += "?date=$date";
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return DailyScoreResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          "Daily Score API failed: ${response.statusCode} ${response.body}");
    }
  }

  // ---------------------------------------------------------------------------
  // GET CALENDAR STATS
  // ---------------------------------------------------------------------------
  Future<CalendarStatsResponse> getCalendarStats({
    int? month,
    int? year,
  }) async {
    final params = [];

    if (month != null) params.add("month=$month");
    if (year != null) params.add("year=$year");

    final query = params.isEmpty ? "" : "?${params.join("&")}";

    final response = await http.get(
      Uri.parse("$baseUrl/calendar-stats/$query"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return CalendarStatsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          "Calendar Stats API failed: ${response.statusCode} ${response.body}");
    }
  }

  // ---------------------------------------------------------------------------
  // GET MONTHLY CHART
  // ---------------------------------------------------------------------------
  Future<MonthlyChartResponse> getMonthlyChart({
    int? month,
    int? year,
  }) async {
    final params = [];

    if (month != null) params.add("month=$month");
    if (year != null) params.add("year=$year");

    final query = params.isEmpty ? "" : "?${params.join("&")}";

    final response = await http.get(
      Uri.parse("$baseUrl/monthly-chart/$query"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return MonthlyChartResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          "Monthly Chart API failed: ${response.statusCode} ${response.body}");
    }
  }
}
