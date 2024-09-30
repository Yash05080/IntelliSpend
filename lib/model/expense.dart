import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
part 'expense.g.dart';

@JsonSerializable()
@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
  });
}
