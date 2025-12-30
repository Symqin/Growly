import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growly/models/habit_model.dart';

class HabitService {
  final CollectionReference _habits = FirebaseFirestore.instance.collection(
    'habits',
  );

  // ===============================
  // AMBIL USER ID (REALTIME)
  // ===============================
  String _uid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    return user.uid;
  }

  // ===============================
  // STREAM HABITS (DASHBOARD)
  // ===============================
  Stream<List<Habit>> getHabits() {
    return _habits
        .where('ownerId', isEqualTo: _uid())
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList(),
        );
  }

  // ===============================
  // ADD HABIT
  // ===============================
  Future<String> addHabitWithDetail({
    required String title,
    required String description,
    required bool reminderEnabled,
    required String reminderTime,
    required String repeat,
  }) async {
    final doc = await _habits.add({
      'title': title,
      'description': description,
      'completedDates': <String>[],
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderRepeat': repeat,
      'ownerId': _uid(),
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

    return doc.id;
  }

  // ===============================
  // UPDATE HABIT (EDIT)
  // ===============================
  Future<void> updateHabit(
    String habitId, {
    required String title,
    required String description,
    required bool reminderEnabled,
    required String reminderTime,
    required String repeat,
  }) async {
    await _habits.doc(habitId).update({
      'title': title,
      'description': description,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderRepeat': repeat,
    });
  }

  // ===============================
  // COMPLETE / UNCOMPLETE
  // ===============================
  Future<void> completeHabit(String habitId) async {
    await _habits.doc(habitId).update({
      'completedDates': FieldValue.arrayUnion([_today()]),
    });
  }

  Future<void> uncompleteHabit(String habitId) async {
    await _habits.doc(habitId).update({
      'completedDates': FieldValue.arrayRemove([_today()]),
    });
  }

  // ===============================
  // DELETE
  // ===============================
  Future<void> deleteHabit(String habitId) async {
    await _habits.doc(habitId).delete();
  }

  // ===============================
  // HELPER
  // ===============================
  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
