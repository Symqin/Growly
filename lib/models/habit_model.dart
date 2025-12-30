import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final List<String> completedDates;
  final String? ownerId;

  // ===== DETAIL =====
  final String? description;
  final bool reminderEnabled;
  final String? reminderTime;
  final String? reminderRepeat;

  // ===== 🔥 PENTING UNTUK STATISTIK =====
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.completedDates,
    required this.createdAt,
    this.ownerId,
    this.description,
    this.reminderEnabled = false,
    this.reminderTime,
    this.reminderRepeat,
  });

  // ===============================
  // FROM FIRESTORE
  // ===============================
  factory Habit.fromMap(Map<String, dynamic> data, String documentId) {
    return Habit(
      id: documentId,
      title: data['title'] ?? '',
      completedDates: List<String>.from(data['completedDates'] ?? []),
      ownerId: data['ownerId'],
      description: data['description'],
      reminderEnabled: data['reminderEnabled'] ?? false,
      reminderTime: data['reminderTime'],
      reminderRepeat: data['reminderRepeat'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ===============================
  // TO FIRESTORE
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completedDates': completedDates,
      'ownerId': ownerId,
      'description': description,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderRepeat': reminderRepeat,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ===============================
  // COPY WITH
  // ===============================
  Habit copyWith({
    String? id,
    String? title,
    List<String>? completedDates,
    String? ownerId,
    String? description,
    bool? reminderEnabled,
    String? reminderTime,
    String? reminderRepeat,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      completedDates: completedDates ?? this.completedDates,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderRepeat: reminderRepeat ?? this.reminderRepeat,
      createdAt: createdAt ?? this.createdAt, // 🔥 PENTING
    );
  }

  // ===============================
  // HELPER: TODAY (yyyy-MM-dd)
  // ===============================
  String today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // ===============================
  // CHECKBOX STATE (AUTO RESET)
  // ===============================
  bool get isDoneToday {
    return completedDates.contains(today());
  }

  // ===============================
  // STREAK CALCULATION
  // ===============================
  int calculateStreak() {
    if (completedDates.isEmpty) return 0;

    final dateSet = completedDates.map((d) => DateTime.parse(d)).toSet();

    int streak = 0;
    DateTime day = DateTime.now();

    while (dateSet.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    )) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
