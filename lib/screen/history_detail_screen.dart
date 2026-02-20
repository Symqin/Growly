import 'package:flutter/material.dart';
import 'package:growly/models/habit_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String date; // yyyy-MM-dd
  final List<Habit> habits;

  const HistoryDetailScreen({
    super.key,
    required this.date,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final targetDate = DateTime.parse(date);

    // 🔥 PERBAIKAN: Filter habit berdasarkan tanggal pembuatan (Hanya Tahun-Bulan-Hari)
    final validHabits = habits.where((h) {
      final createdDateOnly = DateTime(
        h.createdAt.year,
        h.createdAt.month,
        h.createdAt.day,
      );
      final targetDateOnly = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      // Habit valid jika dibuat sebelum atau tepat pada tanggal target
      return !createdDateOnly.isAfter(targetDateOnly);
    }).toList();

    final completed = validHabits
        .where((h) => h.completedDates.contains(date))
        .toList();

    final uncompleted = validHabits
        .where((h) => !h.completedDates.contains(date))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History ${_prettyDate(date)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ...completed.map(
                    (habit) => _historyItem(
                      title: habit.title,
                      time: habit.reminderTime,
                      done: true,
                    ),
                  ),
                  ...uncompleted.map(
                    (habit) => _historyItem(
                      title: habit.title,
                      time: habit.reminderTime,
                      done: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyItem({
    required String title,
    String? time,
    required bool done,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (time != null && time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: done ? Colors.green : Colors.red),
            ),
            child: Icon(
              done ? Icons.check : Icons.close,
              color: done ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  static String _prettyDate(String date) {
    final d = DateTime.parse(date);
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return "${d.day} ${months[d.month - 1]}";
  }
}
