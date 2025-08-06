import 'dart:io';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await FirestoreService.getAttendanceHistory();
      setState(() {
        _history = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat riwayat: $e')),
      );
    }
  }

  Widget _imageWidget(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image);
    }

    return Image.file(
      file,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text('❌ Belum ada data absensi'))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: _imageWidget(item['image_path']),
              title: Text('${item['date']} • ${item['time']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['location_valid'] == true
                        ? '✅ Lokasi valid'
                        : '❌ Lokasi tidak valid',
                  ),
                  Text(
                    '${item['lat']}, ${item['lng']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
