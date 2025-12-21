import 'package:flutter/material.dart';
import 'package:growly/models/habit_model.dart';
import 'package:growly/screen/add_habit_screen.dart';
import 'package:growly/screen/habit_history_screen.dart';
import 'package:growly/services/habit_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HabitService habitService = HabitService();

  /// state lokal per habit
  final Map<String, bool> _localChecked = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Growly",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitHistoryScreen()),
              );
            },
          ),
        ],
      ),

      // 🔁 realtime Firestore
      body: StreamBuilder<List<Habit>>(
        stream: habitService.getHabits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= EMPTY STATE =================
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Habits",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddHabitScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        "No habit yet",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ================= DATA STATE =================
          final habits = snapshot.data!;

          final totalHabits = habits.length;
          final completedToday = habits.where((h) => h.isDoneToday).length;

          final progress = totalHabits == 0
              ? 0.0
              : completedToday / totalHabits;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌿 DAILY TRACK CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34C759), Color(0xFF0BA360)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Daily Track",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 14,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 0, 221, 70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🗓️ HABITS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Habits",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddHabitScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ================= LIST =================
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: StatefulBuilder(
                                builder: (context, setLocalState) {
                                  bool checked =
                                      _localChecked[habit.id] ??
                                      habit.isDoneToday;

                                  return CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => habitService.deleteHabit(
                                            habit.id,
                                          ),
                                          child: Container(
                                            width: 26,
                                            height: 26,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habit.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "🔥 Streak: ${habit.calculateStreak()} hari",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    value: checked,
                                    activeColor: Colors.green,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    onChanged: (value) async {
                                      setLocalState(() {
                                        _localChecked[habit.id] =
                                            value ?? false;
                                      });

                                      if (value == true) {
                                        await habitService.completeHabit(
                                          habit.id,
                                        );
                                      } else {
                                        await habitService.uncompleteHabit(
                                          habit.id,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
