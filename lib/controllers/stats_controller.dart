import 'package:get/get.dart';

import '../models/stats_model.dart';
import '../services/stats_api_service.dart';
import '../services/auth_service.dart';

class StatsController extends GetxController {
  final StatsApiService _apiService = StatsApiService();

  // Observable variables
  var isLoading = true.obs;

  var dailyScore = Rx<DailyScoreResponse?>(null);
  var calendarStats = Rx<CalendarStatsResponse?>(null);
  var monthlyChart = Rx<MonthlyChartResponse?>(null);

  var selectedMonth = DateTime.now().obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    try {
      final authService = Get.find<AuthService>();
      final token = authService.token;

      if (token.isNotEmpty) {
        _apiService.setAuthToken(token);
        loadAllData();
      } else {
        errorMessage.value = 'Please login to view stats';
        isLoading.value = false;
      }
    } catch (e) {
      print('❌ Error getting auth token: $e');
      errorMessage.value = 'Authentication error. Please login again.';
      isLoading.value = false;
    }
  }

  /// ==============================================================
  /// LOAD ALL DATA IN ONE SHOT (refresh, pull-to-refresh)
  /// ==============================================================

  Future<void> loadAllData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([
        fetchDailyScore(),
        fetchCalendarStats(),
        fetchMonthlyChart(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load stats: $e';
      print('❌ Stats load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ==============================================================
  /// API CALLS
  /// ==============================================================

  Future<void> fetchDailyScore({String? date}) async {
    try {
      final response = await _apiService.getDailyScore(date: date);
      dailyScore.value = response;
    } catch (e) {
      print('❌ Error fetching daily score: $e');
    }
  }

  Future<void> fetchCalendarStats() async {
    try {
      final response = await _apiService.getCalendarStats(
        month: selectedMonth.value.month,
        year: selectedMonth.value.year,
      );
      calendarStats.value = response;
    } catch (e) {
      print('❌ Error loading calendar stats: $e');
    }
  }

  Future<void> fetchMonthlyChart() async {
    try {
      final response = await _apiService.getMonthlyChart(
        month: selectedMonth.value.month,
        year: selectedMonth.value.year,
      );
      monthlyChart.value = response;
    } catch (e) {
      print('❌ Error loading monthly charts: $e');
    }
  }

  /// ==============================================================
  /// MONTH NAVIGATION
  /// ==============================================================

  void changeMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    fetchCalendarStats();
    fetchMonthlyChart();
  }

  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    fetchCalendarStats();
    fetchMonthlyChart();
  }

  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    fetchCalendarStats();
    fetchMonthlyChart();
  }

  /// ==============================================================
  /// REFRESH
  /// ==============================================================

  Future<void> refresh() async {
    await loadAllData();
  }
}
