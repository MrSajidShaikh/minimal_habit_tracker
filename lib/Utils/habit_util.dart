import 'package:minimal_habit_tracker/Models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completeDays){
  final today = DateTime.now();
  return completeDays.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
  );
}

Map<DateTime, int > prepHeatMapDataset(List<HabitModel> habits){
  Map<DateTime, int> dataset = {};

  for(var habit in habits){
    for(var date in habit.CompletedDays ){
      final normalizeDate = DateTime(date.year, date.month, date.day);

      if(dataset.containsKey(normalizeDate)){
        dataset[normalizeDate] = dataset[normalizeDate]! + 1;
      }
      else{
        dataset[normalizeDate] = 1 ;
      }
    }
  }
  return dataset;
}