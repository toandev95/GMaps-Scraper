class LogItem {
  final String text;
  final DateTime createdAt;

  LogItem({
    required this.text,
    required this.createdAt,
  });

  static LogItem build(String text, [DateTime? createdAt]) => LogItem(
        text: text,
        createdAt: createdAt ?? DateTime.now(),
      );
}
