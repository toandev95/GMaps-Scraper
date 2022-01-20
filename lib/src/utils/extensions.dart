import 'package:intl/intl.dart';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

extension IntlDateTimeFormat on DateTime {
  String format([
    String? newPattern = 'hh:mm:ss dd-MM-yyyy',
    String? locale = 'vi',
  ]) =>
      DateFormat(newPattern, locale).format(this);
}
