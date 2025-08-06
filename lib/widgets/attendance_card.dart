import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String date;
  final String time;
  final String imageUrl;
  final bool locationValid;

  const AttendanceCard({
    super.key,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.locationValid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text('$date — $time'),
        subtitle: Text(locationValid ? '✅ Lokasi valid' : '❌ Lokasi tidak valid'),
      ),
    );
  }
}
