import 'package:isar/isar.dart';
part 'app_setting_model.g.dart';

@Collection()

class AppSettings{
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}