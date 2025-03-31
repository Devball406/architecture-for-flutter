class Utils {
  static const double MILLIS_LIMIT = 1000.0;
  static const double SECONDS_LIMIT = 60 * MILLIS_LIMIT;
  static const double MINUTES_LIMIT = 60 * SECONDS_LIMIT;
  static const double HOURS_LIMIT = 24 * MINUTES_LIMIT;
  static const double DAYS_LIMIT = 30 * HOURS_LIMIT;

  Utils._();

  static String getFormatTime(DateTime date) {
    final now = DateTime.now().millisecondsSinceEpoch;
    int sub = now - date.millisecondsSinceEpoch;
    return switch (sub) {
      < MILLIS_LIMIT => "刚刚",
      < SECONDS_LIMIT => "${(sub / MILLIS_LIMIT).round()} 秒前",
      < MINUTES_LIMIT => "${(sub / SECONDS_LIMIT).round()} 分钟前",
      < HOURS_LIMIT => "${(sub / SECONDS_LIMIT).round()} 小时前",
      < DAYS_LIMIT => "${(sub / SECONDS_LIMIT).round()} 天前",
      _ => date.toIso8601String()
    };
  }
}
