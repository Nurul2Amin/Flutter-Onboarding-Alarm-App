// home_screen.dart
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../../../helpers/date_time_helper.dart';
import '../services/notification_service.dart';
import '../services/alarm_database.dart';

class HomeScreen extends StatefulWidget {
  // Add a nullable field to hold the selected location
  final String? selectedLocation;

  // Update the constructor to accept the location
  const HomeScreen({super.key, this.selectedLocation});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Alarm> _alarms = [];

  Future<void> _loadAlarms() async {
    final alarms = await AlarmDatabase.getAlarms();
    setState(() => _alarms = alarms);
  }

  Future<void> _addAlarm() async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (picked == null) return;

    var dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));

    final insertedId = await AlarmDatabase.insertAlarm(Alarm(time: dt));
    final newAlarm = Alarm(id: insertedId, time: dt);

    setState(() => _alarms.add(newAlarm));

    await NotificationService.scheduleAlarm(dt, insertedId);
  }

  Future<void> _toggleAlarm(Alarm alarm, bool isActive) async {
    final updated = Alarm(id: alarm.id, time: alarm.time, isActive: isActive);
    await AlarmDatabase.updateAlarm(updated);

    setState(() {
      final i = _alarms.indexWhere((a) => a.id == alarm.id);
      _alarms[i] = updated;
    });

    if (isActive) {
      await NotificationService.scheduleAlarm(alarm.time, alarm.id!);
    } else {
      await NotificationService.cancelAlarm(alarm.id!);
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    if (alarm.id != null) {
      await AlarmDatabase.deleteAlarm(alarm.id!);
      await NotificationService.cancelAlarm(alarm.id!);
    }
    setState(() => _alarms.removeWhere((a) => a.id == alarm.id));
  }

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alarms")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the selected location here
            if (widget.selectedLocation != null) ...[
              const Text(
                "Selected Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.selectedLocation!,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: _alarms.isEmpty
                  ? const Center(
                      child: Text(
                        "No alarms yet. Tap + to add one.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = _alarms[index];
                        return Dismissible(
                          key: ValueKey(alarm.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteAlarm(alarm),
                          child: Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                DateTimeHelper.formatTime(alarm.time),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                DateTimeHelper.formatDate(alarm.time),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Switch(
                                value: alarm.isActive,
                                activeColor: Colors.deepPurple,
                                onChanged: (v) => _toggleAlarm(alarm, v),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}