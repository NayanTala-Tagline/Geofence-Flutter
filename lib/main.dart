import 'dart:convert';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';

import 'package:geofence_demo/Screen/GoogleMap/GoogleMapScreen.dart';
import 'package:geofence_demo/database/dbConnect.dart';
import 'package:geofence_demo/services/NotificationHandler.dart';
import 'package:geofence_demo/services/TerminateDatabase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

// For indicating whether the user is in geofence or not
const String isUserAvailableInGeofence = "isUserAvailableInGeofence";
const String identifier = "identifier";
const String id = "id";
const String name = "name";
const String lat = "lat";
const String long = "long";
const String startTime = "startTime";
const String exitTime = "exitTime";
const String currentExitTime = "CurrentExitTime";
const String currentEnterTime = "CurrentEnterTime";

const EVENTS_KEY = "fetch_event";
const TERMINATE_GEOFENCE_INFO = "terminateGeofenceInfo";

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String timeZone;
  Position location;

  List<Map<String, dynamic>> events = [];

  bool isAvailableInGeofence = false;
  String identifierVar = "Not available";
  int idTerminate = 1000;

  Map<String, dynamic> geofenceInfo = {};
  List<Map<String, dynamic>> terminateGeofenceData = [];

  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    developer.log("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  // Executed in terminate state
  int temp = prefs.getInt('temp') ?? 0;
  temp += 1;
  prefs.setInt('temp', temp);

  // Get Geofecen Info
  isAvailableInGeofence =
      prefs.getBool(isUserAvailableInGeofence) ?? isAvailableInGeofence;
  identifierVar = prefs.getString(identifier) ?? identifierVar;
  idTerminate = prefs.getInt(id) ?? idTerminate;

  // Location
  location = await Geolocator.getCurrentPosition();

  // Get current Time
  timeZone = DateFormat.yMd().add_jm().format(DateTime.now());

  geofenceInfo = {
    "$id": idTerminate,
    "$name": identifierVar.toString(),
    "$lat": location.latitude.toString(),
    "$long": location.longitude.toString(),
    "$startTime": timeZone.toString(),
    "$exitTime": timeZone.toString(),
    "$currentEnterTime": DateTime.now().toString(),
    "$currentExitTime": DateTime.now().toString(),
  };

  // Read fetch_events from SharedPreferences
  String json = prefs.getString(EVENTS_KEY);
  if (json != null) events = jsonDecode(json).cast<Map<String, dynamic>>();
  events.add(geofenceInfo);
  prefs.setString(EVENTS_KEY, jsonEncode(events));

  // Track Geofence change while app is terminated
  String terminateGeofenceList = prefs.getString(TERMINATE_GEOFENCE_INFO);
  if (terminateGeofenceList != null) {
    terminateGeofenceData =
        jsonDecode(terminateGeofenceList).cast<Map<String, dynamic>>();
  }

  await geofencelist().then((value) {
    value.forEach((element) {
      double distanceMeter = Geolocator.distanceBetween(
        double.parse(element.lat),
        double.parse(element.long),
        location.latitude,
        location.longitude,
      );
      if (distanceMeter <= double.parse(element.radius)) {
        terminateGeofenceData.add(
          TerminateGeofenceData(
                  geofenceName: element.name,
                  location: location.latitude.toString() +
                      "|" +
                      location.longitude.toString(),
                  time: timeZone)
              .toJson(),
        );
      }
    });
  });
  prefs.setString(TERMINATE_GEOFENCE_INFO, jsonEncode(terminateGeofenceData));
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) await NotificationHandler().init();
  if (Platform.isAndroid) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TerminateDatabase _terminateDatabase = new TerminateDatabase();
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) NotificationHandler().shedule();
    if (Platform.isAndroid) initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> _events = [];
    List<Map<String, dynamic>> _terminateEvents = [];

    String json = prefs.getString(EVENTS_KEY);
    String terminateJson = prefs.getString(TERMINATE_GEOFENCE_INFO);

    if (json != null) {
      _events = jsonDecode(json).cast<Map<String, dynamic>>();
      await _terminateDatabase.getGeofenceModalData(_events);
    }

    if (terminateJson != null) {
      developer.log(_terminateEvents.toList().toString(), name: "some");
    }

    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          forceAlarmManager: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
        ),
        _onBackgroundFetch, (String taskId) async {
      BackgroundFetch.finish(taskId);
    }).catchError((e) {
      developer.log('[BackgroundFetch] ERROR: $e');
    });

    if (!mounted) return;
  }

  // This method will be executed when the app is in background not terminated
  void _onBackgroundFetch(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int tempBack = prefs.getInt('back') ?? 0;
    tempBack += 1;
    prefs.setInt('back', tempBack);
    developer.log(prefs.getInt('back').toString(),
        name: "Number of Background task Executed");

    // This is the fetch-event callback.
    developer.log('[BackgroundFetch] Event received');

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geofence App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Googlemap(),
    );
  }
}

class TerminateGeofenceData {
  String geofenceName;
  String location;
  String time;

  TerminateGeofenceData({this.geofenceName, this.location, this.time});

  Map<String, dynamic> toJson() => {
        'geofence': geofenceName,
        'location': location,
        'time': time,
      };
}
