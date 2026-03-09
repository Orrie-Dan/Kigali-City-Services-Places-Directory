import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Provides helpers for working with the device's location and geocoding.
///
/// This is a pure Dart service and must not import Flutter UI packages.
class LocationService {
  Future<bool> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return null;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Location?> forwardGeocode(String address) async {
    final locations = await locationFromAddress(address);
    if (locations.isEmpty) return null;
    return locations.first;
  }
}

