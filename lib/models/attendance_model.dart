class Attendance {
  final String date;
  final String time;
  final String imageUrl;
  final bool locationValid;

  Attendance({
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.locationValid,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      imageUrl: map['image_url'] ?? '',
      locationValid: map['location_valid'] ?? false,
    );
  }
}
