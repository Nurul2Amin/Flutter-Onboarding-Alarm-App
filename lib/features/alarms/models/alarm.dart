class Alarm {
  final int? id; // for DB
  final DateTime time;
  bool isActive;

  Alarm({
    this.id,
    required this.time,
    this.isActive = true,
  });

  // Convert Alarm → Map for DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Convert Map → Alarm
  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      time: DateTime.parse(map['time']),
      isActive: map['isActive'] == 1,
    );
  }
}
