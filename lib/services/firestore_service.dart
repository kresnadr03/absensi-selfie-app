import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;
  static final _user = FirebaseAuth.instance.currentUser;

  /// Format tanggal sekarang jadi "yyyy-MM-dd"
  static String get todayDate {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  /// Cek apakah sudah absen hari ini
  static Future<bool> hasCheckedInToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await _firestore
        .collection('attendances')
        .where('user_id', isEqualTo: user.uid)
        .where('date', isEqualTo: todayDate)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<void> submitAttendance({
    required File selfieFile,
    required Position location,
    required bool locationValid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    await _firestore.collection('attendances').add({
      'user_id': user.uid,
      'email': user.email,
      'date': DateFormat('yyyy-MM-dd').format(now),
      'time': DateFormat('HH:mm:ss').format(now),
      'timestamp': now,
      'lat': location.latitude,
      'lng': location.longitude,
      'location_valid': locationValid,
      'image_path': selfieFile.path,
    });
  }

  static Future<List<Map<String, dynamic>>> getAttendanceHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('attendances')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
