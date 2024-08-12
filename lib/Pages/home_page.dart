import 'package:flutter/material.dart';
import 'package:minimal_habit_tracker/Components/my_drawer.dart';
import 'package:minimal_habit_tracker/Components/my_habit_tile.dart';
import 'package:minimal_habit_tracker/Components/my_heat_map.dart';
import 'package:minimal_habit_tracker/DataBase/habit_database.dart';
import 'package:minimal_habit_tracker/Models/habit.dart';
import 'package:provider/provider.dart';
import '../Utils/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController textEditingController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                hintText: "Create a new habit",
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  String newHabitName = textEditingController.text;
                  context.read<HabitDatabase>().addhabit(newHabitName);
                  Navigator.pop(context);
                  textEditingController.clear();
                },
                child: const Text('Save'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  textEditingController.clear();
                },
                child: const Text('Cancel'),
              )
            ],
          ),
    );
  }

  void checkHabitOnOff(bool? value, HabitModel habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(HabitModel habit) {
    textEditingController.text = habit.name;
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: TextField(
              controller: textEditingController,
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  String newHabitName = textEditingController.text;
                  context
                      .read<HabitDatabase>()
                      .updateHabitName(habit.id, newHabitName);
                  Navigator.pop(context);
                  textEditingController.clear();
                },
                child: const Text('Save'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  textEditingController.clear();
                },
                child: const Text('Cancel'),
              )
            ],
          ),
    );
  }

  void deleteHabitBox(HabitModel habit) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Are you sure you want to delete ?"),
            actions: [
              MaterialButton(
                onPressed: () {
                  context.read<HabitDatabase>().deleteHabit(habit.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              )
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 0,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .tertiary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          _buildHeatMap(),
          _builHabitList(),
        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<HabitModel> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(), builder: (context, snapshot) {
      if (snapshot.hasData) {
        return MyHeatMap(
          startDate: snapshot.data!,
          datasets: prepHeatMapDataset(currentHabits),
        );
      }
      else {
        return Container();
      }
    },);
  }


  Widget _builHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<HabitModel> currentHabits = habitDatabase.currentHabits;
    return ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final habit = currentHabits[index];
          bool isCompletedToday = isHabitCompletedToday(habit.CompletedDays);
          return MyHabitTile(
            isCompleted: isCompletedToday,
            text: habit.name,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}
