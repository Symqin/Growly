import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growly/models/habit_model.dart';

class HabitService {
  final CollectionReference habitsCollection = FirebaseFirestore.instance
      .collection('habits');

  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // ===============================
  // STREAM HABITS
  // ===============================
  Stream<List<Habit>> getHabits() {
    return habitsCollection.where('ownerId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) =>
                  Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id),
            )
            .toList();
      },
    );
  }

  // ===============================
  // ADD HABIT (DARI ADD HABIT SCREEN)
  // ===============================
  Future<void> addHabitWithDetail({
    required String title,
    required String description,
    required bool reminderEnabled,
    required String reminderTime,
    required String repeat,
  }) async {
    await habitsCollection.add({
      'title': title,
      'description': description,
      'completedDates': <String>[],
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderRepeat': repeat,
      'ownerId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // UPDATE HABIT (EDIT MODE)
  // ===============================
  Future<void> updateHabit(
    String habitId, {
    required String title,
    required String description,
    required bool reminderEnabled,
    required String reminderTime,
    required String repeat,
  }) async {
    await habitsCollection.doc(habitId).update({
      'title': title,
      'description': description,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderRepeat': repeat,
    });
  }

  // ===============================
  // COMPLETE HABIT (CHECK HARI INI)
  // ===============================
  Future<void> completeHabit(String habitId) async {
    final today = _today();

    await habitsCollection.doc(habitId).update({
      'completedDates': FieldValue.arrayUnion([today]),
    });
  }

  // ===============================
  // UNCOMPLETE HABIT (UNCHECK HARI INI)
  // ===============================
  Future<void> uncompleteHabit(String habitId) async {
    final today = _today();

    await habitsCollection.doc(habitId).update({
      'completedDates': FieldValue.arrayRemove([today]),
    });
  }

  // ===============================
  // DELETE HABIT
  // ===============================
  Future<void> deleteHabit(String habitId) async {
    await habitsCollection.doc(habitId).delete();
  }

  // ===============================
  // HELPER: TODAY FORMAT yyyy-MM-dd
  // ===============================
  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
