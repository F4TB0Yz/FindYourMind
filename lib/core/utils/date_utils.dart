class DateUtils {
  static String todayString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }
}