import 'package:flutter/material.dart';
import 'package:growly/models/habit_model.dart';
import 'package:growly/services/habit_service.dart';
import 'package:growly/services/notification_service.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habitToEdit; // null = add, ada = edit

  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final HabitService habitService = HabitService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _reminderEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 30);
  final String _repeat = "Every day";

  // =====================
  // INIT (EDIT MODE)
  // =====================
  @override
  void initState() {
    super.initState();

    if (widget.habitToEdit != null) {
      final habit = widget.habitToEdit!;
      _nameController.text = habit.title;
      _descController.text = habit.description ?? '';
      _reminderEnabled = habit.reminderEnabled;

      if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) {
        final parts = habit.reminderTime!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
  }

  // =====================
  // PICK TIME
  // =====================
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false, // 🔥 FORCE 12 JAM
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // =====================
  // PERMISSION HANDLER
  // =====================
  Future<bool> _ensureExactAlarmPermission() async {
    final allowed = await NotificationService.ensureExactAlarmPermission();

    if (!allowed && mounted) {
      return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text("Enable Reminder"),
              content: const Text(
                "To remind you on time, please allow exact alarms in system settings.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context, true);
                    await NotificationService.openExactAlarmSettings();
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          ) ??
          false;
    }

    return allowed;
  }

  // =====================
  // SAVE HABIT
  // =====================
  Future<void> _saveHabit() async {
    if (_nameController.text.trim().isEmpty) return;

    final reminderTime =
        "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    String habitId;

    // =====================
    // ADD / UPDATE FIRESTORE
    // =====================
    if (widget.habitToEdit == null) {
      habitId = await habitService.addHabitWithDetail(
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTime,
        repeat: _repeat,
      );
    } else {
      habitId = widget.habitToEdit!.id;

      // cancel notif lama (AMAN)
      await NotificationService.cancel(habitId.hashCode);

      await habitService.updateHabit(
        habitId,
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTime,
        repeat: _repeat,
      );
    }

    // =====================
    // SCHEDULE NOTIFICATION
    // =====================
    if (_reminderEnabled) {
      final allowed = await _ensureExactAlarmPermission();
      if (!allowed) return;

      await NotificationService.scheduleDailyExact(
        id: habitId.hashCode,
        title: _nameController.text.trim(),
        body: 'Time to do your habit 💪',
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Habit" : "Add Habit"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NAME", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Latihan Padel",
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text("GOAL", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Deskripsi",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text("REMINDERS", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Remember to set off time."),
                      Switch(
                        value: _reminderEnabled,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() => _reminderEnabled = val);
                        },
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text(_selectedTime.format(context)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _saveHabit,
                child: Text(
                  isEdit ? "Save Changes" : "Add Habit",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
