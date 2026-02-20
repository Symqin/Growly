import 'package:flutter/material.dart';
import 'package:growly/models/habit_model.dart';
import 'package:growly/services/habit_service.dart';
import 'package:intl/intl.dart';
import 'history_detail_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitService habitService = HabitService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Habit>>(
        stream: habitService.getHabits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = snapshot.data!;
          final DateTime now = DateTime.now();

          // ===============================
          // AGGREGATE GLOBAL DATA
          // ===============================
          final allDates = <String>{};
          for (final h in habits) {
            allDates.addAll(h.completedDates);
          }

          int currentStreak = 0;
          DateTime tempDay = now;
          while (allDates.contains(_fmt(tempDay))) {
            currentStreak++;
            tempDay = tempDay.subtract(const Duration(days: 1));
          }

          int longestStreak = 0;
          for (final h in habits) {
            final s = h.calculateStreak();
            if (s > longestStreak) longestStreak = s;
          }

          final daysActive = allDates.length;

          // 🔥 PERBAIKAN: Filter habit yang sudah ada HARI INI saja untuk Completion Rate
          final habitsExistingToday = habits.where((h) {
            final createdDateOnly = DateTime(
              h.createdAt.year,
              h.createdAt.month,
              h.createdAt.day,
            );
            final todayOnly = DateTime(now.year, now.month, now.day);
            return !createdDateOnly.isAfter(todayOnly);
          }).toList();

          final completedToday = habitsExistingToday
              .where((h) => h.isDoneToday)
              .length;
          final completionRate = habitsExistingToday.isEmpty
              ? 0
              : ((completedToday / habitsExistingToday.length) * 100).round();

          final historyMap = <String, int>{};
          for (final h in habits) {
            for (final d in h.completedDates) {
              historyMap[d] = (historyMap[d] ?? 0) + 1;
            }
          }

          final historyDates = historyMap.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "YOUR PROGRESS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _statCard(
                      icon: Icons.trending_up,
                      color: Colors.green,
                      title: "Current Streak",
                      value: "$currentStreak days",
                    ),
                    _statCard(
                      icon: Icons.emoji_events,
                      color: Colors.blue,
                      title: "Longest Streak",
                      value: "$longestStreak days",
                    ),
                    _statCard(
                      icon: Icons.calendar_today,
                      color: Colors.purple,
                      title: "Days Active",
                      value: "$daysActive",
                    ),
                    _statCard(
                      icon: Icons.percent,
                      color: Colors.orange,
                      title: "Completion Rate",
                      value: "$completionRate%",
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    "History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 18),
                for (final date in historyDates) ...[
                  _buildHistoryItem(
                    context: context,
                    date: date,
                    habits: habits,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem({
    required BuildContext context,
    required String date,
    required List<Habit> habits,
  }) {
    final targetDate = DateTime.parse(date);

    // 🔥 PERBAIKAN: Filter habit yang sudah ada di tanggal tersebut
    final validHabits = habits.where((h) {
      final created = DateTime(
        h.createdAt.year,
        h.createdAt.month,
        h.createdAt.day,
      );
      final target = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      return !created.isAfter(target);
    }).toList();

    final completedCount = validHabits
        .where((h) => h.completedDates.contains(date))
        .length;

    final totalHabitsAtThatTime = validHabits.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryDetailScreen(date: date, habits: habits),
          ),
        );
      },
      child: _historyCard(
        date: date,
        count: completedCount,
        total: totalHabitsAtThatTime,
      ),
    );
  }

  static Widget _statCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static Widget _historyCard({
    required String date,
    required int count,
    required int total,
  }) {
    final percent = total == 0 ? 0.0 : count / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E46),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _prettyDate(date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "${(percent * 100).round()}%",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  static String _prettyDate(String date) {
    final d = DateTime.parse(date);
    return DateFormat("d MMM").format(d);
  }
}
