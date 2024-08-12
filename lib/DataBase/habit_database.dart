import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:minimal_habit_tracker/Models/habit.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/app_setting.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([HabitModelSchema, AppSettingModelSchema],
        directory: dir.path);
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettingModels.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettingModels.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettingModels.where().findFirst();
    return settings?.firstLaunchDate;
  }

  final List<HabitModel> currentHabits = [];

  Future<void> addhabit(String habitName) async {
    final newHabit = HabitModel()..name = habitName;
    await isar.writeTxn(() => isar.habitModels.put(newHabit));
    readHabits();
  }

  Future<void> readHabits() async {
    List<HabitModel> fetchedHabits = await isar.habitModels.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habitModels.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.CompletedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.CompletedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        } else {
          habit.CompletedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }

        await isar.habitModels.put(habit);
      });
    }
    readHabits();
  }

  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habitModels.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habitModels.put(habit);
      });
    }
    readHabits();
  }

  Future<void> deleteHabit(int id) async{
    await isar.writeTxn(() async {
      await isar.habitModels.delete(id);
    });
    readHabits();
  }
}
