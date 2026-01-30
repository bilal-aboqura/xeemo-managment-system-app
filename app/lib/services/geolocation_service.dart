import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'supabase_service.dart';

/// Service for capturing device geolocation
class GeolocationService {
  /// Get current location with permission handling
  /// 
  /// Returns the current position or throws an exception if location
  /// cannot be obtained.
  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException(
          'Location services are disabled. Please enable location services.',
        );
      }

      // Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException(
            'Location permission denied. Please grant location access.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
          'Location permission permanently denied. Please enable in settings.',
        );
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      SupabaseService.logInfo(
        'Location captured: ${position.latitude}, ${position.longitude}',
      );

      return position;
    } catch (e) {
      if (e is LocationException) rethrow;
      SupabaseService.logError('Failed to get location', e);
      throw LocationException('Failed to get location: ${e.toString()}');
    }
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Open app settings for permission management
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}

/// Exception thrown when location operations fail
class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => message;
}
