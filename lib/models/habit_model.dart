class Habit {
  final String id;
  final String title;
  final List<String> completedDates;
  final String? ownerId;

  // ===== TAMBAHAN BARU (AMAN) =====
  final String? description;
  final bool reminderEnabled;
  final String? reminderTime;
  final String? reminderRepeat;

  Habit({
    required this.id,
    required this.title,
    required this.completedDates,
    this.ownerId,

    // ===== TAMBAHAN BARU =====
    this.description,
    this.reminderEnabled = false,
    this.reminderTime,
    this.reminderRepeat,
  });

  // ===============================
  // FACTORY FROM FIRESTORE MAP
  // ===============================
  factory Habit.fromMap(Map<String, dynamic> data, String documentId) {
    return Habit(
      id: documentId,
      title: data['title'] as String,
      completedDates: List<String>.from(data['completedDates'] ?? []),
      ownerId: data['ownerId'] as String?,

      // ===== TAMBAHAN BARU =====
      description: data['description'] as String?,
      reminderEnabled: data['reminderEnabled'] ?? false,
      reminderTime: data['reminderTime'] as String?,
      reminderRepeat: data['reminderRepeat'] as String?,
    );
  }

  // ===============================
  // TO FIRESTORE MAP
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completedDates': completedDates,
      'ownerId': ownerId,

      // ===== TAMBAHAN BARU =====
      'description': description,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderRepeat': reminderRepeat,
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

    // ===== TAMBAHAN BARU =====
    String? description,
    bool? reminderEnabled,
    String? reminderTime,
    String? reminderRepeat,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      completedDates: completedDates ?? this.completedDates,
      ownerId: ownerId ?? this.ownerId,

      // ===== TAMBAHAN BARU =====
      description: description ?? this.description,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderRepeat: reminderRepeat ?? this.reminderRepeat,
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
