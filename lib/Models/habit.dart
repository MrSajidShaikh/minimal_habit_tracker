import 'package:isar/isar.dart';
part 'habit_model.g.dart';

@Collection()

class HabitModel{
  Id id = Isar.autoIncrement;
  late String name;
  List<DateTime> CompletedDays = [

  ];
}