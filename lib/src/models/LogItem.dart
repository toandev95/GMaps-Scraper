enum LogLevel {
  INFO,
  WARNING,
  ERROR,
}

class LogItem {
  LogLevel level;
  String? message;
  DateTime? logAt;

  LogItem({
    this.level = LogLevel.INFO,
    this.message,
    this.logAt,
  });

  static LogItem log(LogLevel level, String message) {
    return LogItem(
      level: level,
      message: message,
      logAt: DateTime.now(),
    );
  }

  static LogItem info(String message) {
    return log(LogLevel.INFO, message);
  }

  static LogItem warning(String message) {
    return log(LogLevel.WARNING, message);
  }

  static LogItem error(String message) {
    return log(LogLevel.ERROR, message);
  }
}
