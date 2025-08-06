import 'package:geolocator/geolocator.dart';

class LocationService {
  // Titik kantor
  static const double officeLat = -6.200000;
  static const double officeLng = 106.816666;
  static const double maxRadiusMeters = 100;

  /// Cek dan request izin lokasi
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Ambil posisi saat ini
  static Future<Position?> getCurrentPosition() async {
    bool hasPermission = await checkPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Hitung jarak dari kantor
  static Future<bool> isInsideOfficeRadius(Position pos) async {
    double distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      officeLat,
      officeLng,
    );

    return distance <= maxRadiusMeters;
  }
}
