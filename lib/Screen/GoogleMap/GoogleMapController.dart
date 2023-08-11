import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart' as bl;
import 'package:background_locator/location_dto.dart' as blDto;
import 'package:background_locator/settings/android_settings.dart' as blAndroid;
import 'package:background_locator/settings/ios_settings.dart' as blIos;
import 'package:background_locator/settings/locator_settings.dart' as blSetting;
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geofence_demo/Utils/String_Value.dart';
import 'package:geofence_demo/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:location/location.dart' as location;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Modal/Geofence_ModalData.dart';
import '../../Utils/Color.dart';
import '../../database/dbConnect.dart';

enum HasAllPermissions { YES, NO, ASK }

class GoogleMapGetController extends GetxController {
  double zoom = 16.0;
  location.Location currentLocation = new location.Location();
  HasAllPermissions hasAllPermissions = HasAllPermissions.ASK;
  Position currentPositionOfUser;
  LatLng latLng;
  SharedPreferences prefs;
  Timer timer;
  // Markers
  Set<Marker> markers = {};

  // Geofence List
  List<Geofence_ModalData> geofencelistData = [];
  Set<Circle> circles;

  GoogleMapController googlemapcontroller;

  // Terminate App Handling
  static const String _isolateName = "LocatorIsolate";
  static ReceivePort port = ReceivePort();

  @override
  void onInit() {
    super.onInit();

    // Permission handling - Location | GPS
    getPermissions();

    // Geofence intialisation & configuration
    backgroundGeoLocationEvent();

    // Get Geofence data from database and set it to background Geofence using addGeofence
    addGeoFenceData();

    // Add Geofence data to database
    addGeofenceLocationHistory();
  }

  void getTerminatedAppLocationData() async {
    await initDB();
    await userTerminateStateLocation().then((value) {
      if (value.isEmpty) {
        developer.log("Empty List", name: "Stored data when app is terminated");
      } else {
        developer.log(value.toList().toString(),
            name: "Terminated state lcoation data");
      }
    });
  }

  // Ask for Location & GPS permission
  void getPermissions() async {
    prefs = await SharedPreferences.getInstance();
    LocationPermission permission;
    bool serviceEnabled;

    permission = await Geolocator.checkPermission();
    serviceEnabled = await currentLocation.serviceEnabled();

    if (hasAllPermissions == HasAllPermissions.ASK ||
        hasAllPermissions == HasAllPermissions.NO) {
      // Location permission
      if (permission != LocationPermission.always)
        permission = await Geolocator.requestPermission();

      // GPS permission
      if (!serviceEnabled)
        serviceEnabled = await currentLocation.requestService();

      if ((permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) &&
          serviceEnabled) {
        hasAllPermissions = HasAllPermissions.YES;
      } else {
        hasAllPermissions = HasAllPermissions.NO;
      }
      if (hasAllPermissions == HasAllPermissions.YES) getCurrentLocation();
      update();
    }
  }

  void getCurrentLocation() async {
    currentPositionOfUser = await Geolocator.getCurrentPosition();
    latLng =
        LatLng(currentPositionOfUser.latitude, currentPositionOfUser.longitude);
    developer.log(latLng.toString());
    update();
  }

  void changeInLocation({LatLng latLong}) {
    latLng = latLong;
    update();
  }

  void changecameraposition({LatLng updateLatlng}) {
    googlemapcontroller.moveCamera(CameraUpdate.newLatLng(updateLatlng));
    update();
  }

  void setGoogleMapController(GoogleMapController mapController) {
    googlemapcontroller = mapController;
    update();
  }

  // Markers
  void addMarker() {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId("a"),
        draggable: true,
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onDragEnd: (_currentlatLng) {
          latLng = _currentlatLng;
        },
      ),
    );
    update();
  }

  // Geofences Circles
  void getCircles() {
    List<Circle> list = [];
    for (int i = 0; i < geofencelistData.length; i++) {
      var ci = Circle(
        circleId: CircleId(geofencelistData[i].name),
        strokeWidth: 3,
        strokeColor: red,
        fillColor: red.withOpacity(0.5),
        center: LatLng(
          double.parse(geofencelistData[i].lat),
          double.parse(geofencelistData[i].long),
        ),
        radius: double.parse(geofencelistData[i].radius),
      );
      list.add(ci);
    }
    circles = Set.from(list);
    update();
  }

  // Add GeoFence Data
  void addGeoFenceData() async {
    await initDB().whenComplete(() async {
      // Get all available Geofence data from database if available
      await geofencelist().then((geofence) async {
        if (geofencelistData.isNotEmpty) geofencelistData.clear();
        geofencelistData.addAll(geofence);
        update();

        // Remove previously available Geofence & Add Geofence data from database
        removeGeoFenceData();
        for (int i = 0; i < geofencelistData.length; i++) {
          await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
              identifier: geofence[i].name,
              radius: double.parse(geofence[i].radius),
              latitude: double.parse(geofence[i].lat),
              longitude: double.parse(geofence[i].long),
              notifyOnEntry: true, //  notify on entry
              notifyOnExit: true,
              notifyOnDwell: false,
              loiteringDelay: 30000,
              extras: {
                StringValue.geofence_Id: geofence[i].ID,
              })).then((bool success) {
            print(
                '[addGeofence___________________________] success. Latitude: ' +
                    geofence[i].lat +
                    "Longitude: " +
                    geofence[i].long);
          }).catchError((error) {
            print('[addGeofence] FAILURE: $error');
          });
        }
      });
    });
  }

  // Remove Geo-fences
  void removeGeoFenceData() {
    bg.BackgroundGeolocation.removeGeofences().then((bool success) {
      developer.log('[removeGeofences] all geofences have been destroyed');
    });
    // Update the circle available in google map
    getCircles();
  }

  void backgroundGeoLocationEvent() {
    bg.BackgroundGeolocation.onGeofence(_onGeofence);
    bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 3,
        locationUpdateInterval: 5000,
        stopOnTerminate: false,
        startOnBoot: true,
        disableStopDetection: true,
        allowIdenticalLocations: true,
        isMoving: true,
        pausesLocationUpdatesAutomatically: false,
        debug: true,
        preventSuspend: true,
        persistMode: bg.Config.PERSIST_MODE_NONE,
      ),
    ).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.startGeofences();
      }
    });
  }

  Future<void> _onGeofence(GeofenceEvent event) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();

    await initDB();
    List<Geofence_ModalData> isUser = [];

    // List<String> nameOfEnteredGeofence = [];
    // String identifierList = prefs.getString(IDENTIFIER_LIST);
    // if (identifierList != null) {
    //   nameOfEnteredGeofence = jsonDecode(identifierList).cast<String>();
    // }
    // await Geolocator.getCurrentPosition().then((location) async {
    //   await geofencelist().then((value) {
    //     value.forEach((element) {
    //       developer.log(
    //           location.latitude.toString() +
    //               " | " +
    //               location.longitude.toString() +
    //               " | " +
    //               element.lat +
    //               " | " +
    //               element.long,
    //           name: "Hello");

    //       double distanceMeter = Geolocator.distanceBetween(
    //         double.parse(element.lat),
    //         double.parse(element.long),
    //         location.latitude,
    //         location.longitude,
    //       );
    //       developer.log(distanceMeter.toString(), name: "Hello");
    //       if (distanceMeter <= double.parse(element.radius)) {
    //         nameOfEnteredGeofence.add(element.name);
    //       }
    //     });
    //   });
    // });
    // developer.log(nameOfEnteredGeofence.toList().toString(), name: "Hello");
    // prefs.setString(IDENTIFIER_LIST, jsonEncode(nameOfEnteredGeofence));

    developer.log(event.action.toString(), name: "ACTION");
    // If user enters into any registered geofence this event will get triggered
    if (event.action == 'ENTER') {
      // Update Identifier

      prefs.setString(identifier, event.identifier.toString());
      developer.log(prefs.getString(identifier).toString(), name: "Identifier");

      // Is user available in geofence
      prefs.setBool(isUserAvailableInGeofence, true);
      developer.log(prefs.getBool(isUserAvailableInGeofence).toString(),
          name: "$isUserAvailableInGeofence");

      // Get Geofence information in which the user has entered
      isUser = await isUserEnter(event.identifier, "");

      // If it has the same center but the radius is different
      if (isUser.length == 0) {
        // Get geofence info from geofence table & ID
        List<Geofence_ModalData> userhistorylist =
            await user_geofence(event.identifier);

        // Save the current Geofence ID
        prefs.setInt(id, userhistorylist[0].ID);
        developer.log(prefs.getInt(id).toString(), name: "$id");

        var geofence = Geofence_ModalData(
          GeoFenceID: userhistorylist[0].ID,
          name: event.identifier,
          enterTime: currentDateTime(),
          exitTime: "",
          CurrentEnterTime: DateTime.now().toString(),
          CurrentExitTime: "",
        );

        // Add data to another table with Same ID
        await insert_enter_exit_user_history(geofence).whenComplete(() async {
          developer.log('onGeofence_Enter__________________________ $event');
          if (isUser.isNotEmpty) isUser.clear();
          isUser = await isUserEnter(event.identifier, "");
          for (int i = 0; i < isUser.length; i++)
            setGeofenceData(event.identifier, isUser[i].ID);
        });
      }
    } else if (event.action == 'EXIT') {
      // Update Identifier
      prefs.setString(identifier, event.identifier.toString());
      developer.log(prefs.getString(identifier).toString(), name: "Identifier");

      // Is user available in geofence
      prefs.setBool(isUserAvailableInGeofence, false);
      developer.log(prefs.getBool(isUserAvailableInGeofence).toString(),
          name: "$isUserAvailableInGeofence");

      // Get Geofence enter time & data based on its identifier
      var isUser = await isUserEnter(event.identifier, "");

      // Save the current Geofence ID
      prefs.setInt(id, isUser[0].ID);
      developer.log(prefs.getInt(id).toString(), name: "$id");

      // Set the exit time for exited Geofence
      var geofence = Geofence_ModalData(
        ID: isUser[0].ID,
        exitTime: currentDateTime(),
        CurrentExitTime: DateTime.now().toString(),
      );

      // Update this to database
      await update_exit_time(geofence).whenComplete(() async {
        developer.log('onGeofence_Exit__________________________ $event');
        prefs.setBool(StringValue.isgeofence_add, false);
        addGeofenceLocationHistory();
      });
    }
  }

  Future<void> setGeofenceData(String identifier, int Id) async {
    prefs.setBool(StringValue.isgeofence_add, true);
    prefs.setInt(StringValue.geofence_Id, Id);
    prefs.setString(StringValue.geofence_Name, identifier);
    addGeofenceLocationHistory();
  }

  Future<void> addGeofenceLocationHistory() async {
    await initDB();
    prefs = await SharedPreferences.getInstance();
    var isgeofence = prefs.getBool(StringValue.isgeofence_add) ?? false;
    if (isgeofence) {
      var geofence_name = prefs.getString(StringValue.geofence_Name);
      var geofenceId = prefs.getInt(StringValue.geofence_Id);
      if (latLng == null) {
        Position position = await Geolocator.getCurrentPosition();
        latLng = LatLng(position.latitude, position.longitude);
        update();
      }

      timer = Timer.periodic(Duration(minutes: 15), (Timer t) async {
        print("latlong" + latLng.toString());
        var geofence = Geofence_ModalData(
            ID: geofenceId,
            name: geofence_name,
            lat: latLng.latitude.toString(),
            long: latLng.longitude.toString(),
            startTime: currentDateTime());
        await insert_user_Location_history(geofence).whenComplete(() {
          print('Enter_Geofence_Location__________________________');
        });
      });
    } else {
      timer?.cancel();
    }
  }

  String currentDateTime() => DateFormat.yMd().add_jm().format(DateTime.now());

  /// Terminate Lcoation Tracking

  void startLocationService({GeofenceEvent event}) async {
    bl.BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      autoStop: false,
      iosSettings: blIos.IOSSettings(
        accuracy: blSetting.LocationAccuracy.NAVIGATION,
        distanceFilter: 0,
      ),
      androidSettings: blAndroid.AndroidSettings(
        accuracy: blSetting.LocationAccuracy.NAVIGATION,
        interval: 5,
        distanceFilter: 0,
        androidNotificationSettings: blAndroid.AndroidNotificationSettings(
          notificationChannelName: 'Location tracking',
          notificationTitle: 'Track Location',
          notificationMsg: 'App is running in background',
          notificationBigMsg:
              'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
          notificationIcon: '',
          notificationIconColor: Colors.grey,
          notificationTapCallback: LocationCallbackHandler.notificationCallback,
        ),
      ),
    );
  }

  Future<void> _updateNotificationText(blDto.LocationDto data) async {
    if (data == null) return;

    await bl.BackgroundLocator.updateNotificationText(
        title: "New location received",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

  void removeTerminateTracking() async {
    bl.BackgroundLocator.unRegisterLocationUpdate();
    // IsolateNameServer.removePortNameMapping(_isolateName);
    final _isRunning = await bl.BackgroundLocator.isServiceRunning();
    developer.log(_isRunning.toString(), name: "Location service is running");
  }

  Future<void> saveLocationDataToDatabase(dynamic data) async {
    await _updateNotificationText(data);
    await initDB();
    blDto.LocationDto location = data;

    // Save data to SQLite here
    var geofence = Geofence_ModalData(
      GeoFenceID: 1,
      name: "Terminate tracking",
      lat: location.latitude.toString(),
      long: location.longitude.toString(),
    );
    await insertTerminateGeofence(geofence);
  }

  Future<void> initPlatformState() async =>
      await bl.BackgroundLocator.initialize();
}

class LocationCallbackHandler {
  static void callback(blDto.LocationDto locationDto) async {
    // This will look upto a registered port and transmit the data

    final SendPort send =
        IsolateNameServer.lookupPortByName(GoogleMapGetController._isolateName);
    developer.log(locationDto.toString(), name: "some name");
    send?.send(locationDto);
  }

  //Optional
  static void notificationCallback() {
    developer.log('User clicked on the notification');
  }
}
