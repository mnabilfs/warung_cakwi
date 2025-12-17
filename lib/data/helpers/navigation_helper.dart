import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class NavigationHelper {
  // Koordinat Warung Cakwi
  static const double warungLatitude = -7.901906;
  static const double warungLongitude = 112.582788;
  static const LatLng warungLocation = LatLng(warungLatitude, warungLongitude);

  /// Hitung jarak menggunakan Geolocator (dalam meter)
  static double calculateDistance(Position userPosition) {
    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      warungLatitude,
      warungLongitude,
    );
  }

  /// Format jarak ke string yang readable
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      double km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  /// Estimasi waktu perjalanan
  /// Asumsi: 
  /// - Jalan kaki: 5 km/jam
  /// - Motor/Mobil: 40 km/jam (dalam kota)
  static Map<String, String> estimateTime(double distanceInMeters) {
    double distanceInKm = distanceInMeters / 1000;

    // Estimasi jalan kaki (5 km/jam)
    double walkingHours = distanceInKm / 5;
    int walkingMinutes = (walkingHours * 60).round();

    // Estimasi kendaraan (40 km/jam)
    double drivingHours = distanceInKm / 40;
    int drivingMinutes = (drivingHours * 60).round();

    return {
      'walking': _formatMinutesToTime(walkingMinutes),
      'driving': _formatMinutesToTime(drivingMinutes),
    };
  }

  static String _formatMinutesToTime(int minutes) {
    if (minutes < 1) {
      return '< 1 menit';
    } else if (minutes < 60) {
      return '$minutes menit';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $remainingMinutes menit';
      }
    }
  }

  /// Get bearing/arah dari user ke warung (dalam derajat)
  static double getBearing(Position userPosition) {
    return Geolocator.bearingBetween(
      userPosition.latitude,
      userPosition.longitude,
      warungLatitude,
      warungLongitude,
    );
  }

  /// Convert bearing ke arah mata angin (N, NE, E, SE, S, SW, W, NW)
  static String bearingToDirection(double bearing) {
    // Normalize bearing to 0-360
    bearing = (bearing + 360) % 360;

    if (bearing >= 337.5 || bearing < 22.5) {
      return 'Utara';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      return 'Timur Laut';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      return 'Timur';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      return 'Tenggara';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      return 'Selatan';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      return 'Barat Daya';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      return 'Barat';
    } else {
      return 'Barat Laut';
    }
  }

  /// Get navigation info lengkap
  static Map<String, dynamic> getNavigationInfo(Position userPosition) {
    double distance = calculateDistance(userPosition);
    double bearing = getBearing(userPosition);
    Map<String, String> timeEstimate = estimateTime(distance);

    return {
      'distance': distance,
      'distanceFormatted': formatDistance(distance),
      'bearing': bearing,
      'direction': bearingToDirection(bearing),
      'walkingTime': timeEstimate['walking'],
      'drivingTime': timeEstimate['driving'],
    };
  }

  /// Generate list of intermediate points untuk polyline (rute)
  static List<LatLng> generateRouteLine(Position userPosition) {
    return [
      LatLng(userPosition.latitude, userPosition.longitude),
      warungLocation,
    ];
  }
}