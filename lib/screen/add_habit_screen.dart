import 'package:flutter/material.dart';
import 'package:growly/services/habit_service.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final HabitService habitService = HabitService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _reminderEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 30);
  String _repeat = "Every day";

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveHabit() async {
    if (_nameController.text.trim().isEmpty) return;

    await habitService.addHabitWithDetail(
      title: _nameController.text.trim(),
      description: _descController.text.trim(),
      reminderEnabled: _reminderEnabled,
      reminderTime:
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
      repeat: _repeat,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Habit"),
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
                      const Text(
                        "Remember to set off time for a workout today.",
                        style: TextStyle(fontSize: 13),
                      ),
                      Switch(
                        value: _reminderEnabled,
                        onChanged: (val) {
                          setState(() {
                            _reminderEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                        const SizedBox(width: 12),
                        const Icon(Icons.notifications_none, size: 18),
                        const SizedBox(width: 6),
                        Text(_repeat),
                      ],
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
                child: const Text(
                  "Add Habit",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
