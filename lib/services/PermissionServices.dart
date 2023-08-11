import 'package:geolocator/geolocator.dart';

import 'package:location/location.dart';
import 'dart:developer' as developer;

class PermissionServices {
  Location _currentLocation = new Location();

  // Location permission Access
  Future<bool> requestLocationPermission() async {
    await Geolocator.requestPermission().then((value) {
      switch (value) {
        case LocationPermission.always:
          developer.log("always");
          return true;
          break;
        case LocationPermission.whileInUse:
          developer.log("while in use");
          return true;
          break;
        case LocationPermission.denied:
          developer.log("denied");
          return false;
          break;
        case LocationPermission.deniedForever:
          developer.log("denied forever");
          return false;
          break;
        default:
          developer.log("default");
          return false;
      }
    });
    developer.log("always");
    return false;
  }

  // GPS permission access
  Future<bool> isGpsServiceEnabled() async {
    await _currentLocation.serviceEnabled().then((value) async {
      developer.log(value.toString() + " gps");
      if (value) return true;
      await _currentLocation.requestService().then((value) {
        developer.log(value.toString() + " gps");
        if (value) return true;
      });
    });
    return false;
  }
}
