import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../services/camera_service.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../screens/attendance_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  bool _locationValid = false;
  File? _selfie;
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _checkAbsenceStatus();
  }

  Future<void> _loadLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      final valid = await LocationService.isInsideOfficeRadius(pos);
      setState(() {
        _currentPosition = pos;
        _locationValid = valid;
      });
    }
  }

  Future<void> _checkAbsenceStatus() async {
    final isChecked = await FirestoreService.hasCheckedInToday();
    setState(() => _isCheckedIn = isChecked);
  }

  void _absenSekarang() async {
    if (_selfie == null || _currentPosition == null) return;

    try {
      await FirestoreService.submitAttendance(
        selfieFile: _selfie!,
        location: _currentPosition!,
        locationValid: _locationValid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Absensi berhasil dikirim')),
      );

      setState(() => _isCheckedIn = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan absensi: $e')),
      );
    }
  }

  void _ambilSelfie() async {
    final file = await CameraService.takeSelfie(context);
    if (file != null) {
      setState(() => _selfie = file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Pengguna';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Absensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text('Selamat datang, $email'),
            const SizedBox(height: 16),
            Text('Waktu: ${DateTime.now()}'),
            const SizedBox(height: 8),
            Text(_currentPosition == null
                ? 'Lokasi: Memuat...'
                : 'Lokasi: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
            const SizedBox(height: 8),
            Text('Status lokasi: ${_locationValid ? '✅ Dalam radius' : '❌ Di luar radius'}'),
            const SizedBox(height: 8),
            Text('Status absensi: ${_isCheckedIn ? '✅ Sudah absen' : '❌ Belum absen'}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _ambilSelfie,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Selfie'),
            ),
            if (_selfie != null)
              Image.file(_selfie!, height: 160),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (_locationValid && _selfie != null && !_isCheckedIn)
                  ? _absenSekarang
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Absen Sekarang'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                );
              },
              child: const Text('Lihat Riwayat Absensi'),
            ),
          ],
        ),
      ),
    );
  }
}
