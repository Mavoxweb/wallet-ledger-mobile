import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';

/// Brasília é UTC−3 o ano todo: o Brasil não tem horário de verão desde 2019.
/// Um deslocamento fixo evita depender do fuso do aparelho (um celular em
/// Lisboa mostraria os dias errados).
const brasiliaOffset = Duration(hours: -3);

const _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

class DayGroup {
  const new({required this.label, required this.items});

  final String label;
  final List<Movement> items;
}

/// O instante convertido para o "relógio de parede" de Brasília. O resultado
/// continua marcado como UTC, mas os campos (dia, hora) são os de Brasília.
DateTime _wall(DateTime instant) => instant.toUtc().add(brasiliaOffset);

/// Agrupa por dia de Brasília, mantendo a ordem recebida (a API já manda da
/// mais nova para a mais antiga).
List<DayGroup> groupByDay(List<Movement> items, DateTime now) {
  final today = _dateOnly(_wall(now));
  final groups = <DayGroup>[];
  DateTime? currentDay;

  for (final item in items) {
    final day = _dateOnly(_wall(item.createdAt));
    if (day != currentDay) {
      groups.add(DayGroup(label: _label(day, today), items: []));
      currentDay = day;
    }
    groups.last.items.add(item);
  }
  return groups;
}

String timeOfDay(DateTime instant) {
  final wall = _wall(instant);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(wall.hour)}:${two(wall.minute)}';
}

DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

String _label(DateTime day, DateTime today) {
  final days = today.difference(day).inDays;
  if (days == 0) return 'Hoje';
  if (days == 1) return 'Ontem';
  final base = '${day.day} de ${_months[day.month - 1]}';
  return day.year == today.year ? base : '$base de ${day.year}';
}
