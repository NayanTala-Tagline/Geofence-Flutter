import 'dart:async';
import 'dart:developer' as developer;

import 'package:geofence_demo/Modal/Geofence_ModalData.dart';
import 'package:geofence_demo/Utils/String_Value.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> database;

Future initDB() async {
  if (database != null) return database;
  String databasesPath = await getDatabasesPath();

  database = openDatabase(
    join(databasesPath, StringValue.database_name),
    onCreate: (db, version) async {
      // Table for entering geofence Information
      await db.execute("CREATE TABLE " +
          StringValue.table_name +
          " "
              "(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "name TEXT,"
              "lat TEXT,"
              "long TEXT,"
              "radius TEXT"
              ")");

      await db.execute("CREATE TABLE " +
          StringValue.user_enter_exit_history +
          " "
              "(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "GeoFenceID INTEGER,"
              "name TEXT, "
              "CurrentEnterTime TEXT, "
              "CurrentExitTime TEXT, "
              "enterTime TEXT, "
              "exitTime TEXT)");

      await db.execute("CREATE TABLE " +
          StringValue.user_location_history +
          "("
              "Id INTEGER,"
              "name TEXT,"
              "lat TEXT,"
              "long TEXT,"
              "startTime TEXT"
              ")");

      await db.execute("CREATE TABLE " +
          StringValue.termnate_location_data +
          "("
              "Id INTEGER,"
              "name TEXT,"
              "lat TEXT,"
              "long TEXT"
              ")");
    },
    version: 1,
  );
  return database;
}

// Insert Geofence Data
Future<void> insertGeofence(Geofence_ModalData geofence) async {
  final Database db = await database;
  await db.insert(
    StringValue.table_name,
    geofence.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Insert Geofence enter history Data
Future<void> insert_enter_exit_user_history(Geofence_ModalData geofence) async {
  final Database db = await database;
  await db.insert(
    StringValue.user_enter_exit_history,
    geofence.enter_exit_toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// insert_exit_time
Future update_exit_time(Geofence_ModalData geofence) async {
  final Database db = await database;
  await db.rawUpdate(
      'UPDATE ' +
          StringValue.user_enter_exit_history +
          ' SET exitTime = ?,CurrentExitTime = ?  WHERE ID = ?',
      [geofence.exitTime, geofence.CurrentExitTime, geofence.ID]);
}

// Insert User 15 min loction history data
Future<void> insert_user_Location_history(Geofence_ModalData geofence) async {
  final Database db = await database;
  await db.insert(
    StringValue.user_location_history,
    geofence.userLocationtoMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// get all the Geofence Data
Future<List<Geofence_ModalData>> geofencelist() async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query(StringValue.table_name);
  return List.generate(
    maps.length,
    (i) {
      return Geofence_ModalData(
        ID: maps[i]['ID'],
        name: maps[i]['name'].toString(),
        lat: maps[i]['lat'],
        long: maps[i]['long'],
        radius: maps[i]['radius'],
      );
    },
  );
}

//Get UserHistory
Future<List<Geofence_ModalData>> user_history() async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query(StringValue.user_enter_exit_history);
  developer.log(maps.toString());
  return List.generate(
    maps.length,
    (i) {
      return Geofence_ModalData(
        ID: maps[i]['ID'],
        name: maps[i]['name'].toString(),
        GeoFenceID: maps[i]['GeoFenceID'],
        enterTime: maps[i]['enterTime'],
        exitTime: maps[i]['exitTime'],
        CurrentEnterTime: maps[i]['CurrentEnterTime'],
        CurrentExitTime: maps[i]['CurrentExitTime'],
      );
    },
  );
}

Future<List<Geofence_ModalData>> isUserEnter(
    String event_name, String exit_Time) async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
      StringValue.user_enter_exit_history,
      where: "name = ? and exitTime = ?",
      whereArgs: [event_name, exit_Time]);
  return List.generate(
    maps.length,
    (i) {
      return Geofence_ModalData(
        ID: maps[i]['ID'],
        name: maps[i]['name'].toString(),
        GeoFenceID: maps[i]['GeoFenceID'],
        enterTime: maps[i]['enterTime'],
        exitTime: maps[i]['exitTime'],
        CurrentEnterTime: maps[i]['CurrentEnterTime'],
        CurrentExitTime: maps[i]['CurrentExitTime'],
      );
    },
  );
}

// Get geofence data based on Name/Identifier
Future<List<Geofence_ModalData>> user_geofence(String name) async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.query(StringValue.table_name,
      where: "name = ?", whereArgs: [name.toLowerCase()]);
  return List.generate(
    maps.length,
    (i) {
      return Geofence_ModalData(
        ID: maps[i]['ID'],
        name: maps[i]['name'].toString(),
        lat: maps[i]['lat'],
        long: maps[i]['long'],
        startTime: maps[i]['startTime'],
      );
    },
  );
}

// Get UserLocation
Future<List<Geofence_ModalData>> user_location(int id) async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
      StringValue.user_location_history,
      where: "ID = ?",
      whereArgs: [id]);
  return List.generate(
    maps.length,
    (i) {
      return Geofence_ModalData(
        ID: maps[i]['ID'],
        name: maps[i]['name'].toString(),
        lat: maps[i]['lat'],
        long: maps[i]['long'],
        startTime: maps[i]['startTime'],
      );
    },
  );
}

// Delete Geofence Item based on Id
Future<void> deletegeofence(int Id) async {
  final db = await database;
  await db.rawDelete("DELETE FROM " + StringValue.table_name + " WHERE ID = ?",
      ['$Id']).whenComplete(
    () => developer.log("Removed From Geofence"),
  );
}

// Delete Geofence tracker history based on Id
Future<void> deleteTrackerhistory(int id) async {
  final db = await database;
  await db.rawDelete(
      "DELETE FROM " + StringValue.user_enter_exit_history + " WHERE ID = ?", [
    '$id'
  ]).whenComplete(() => developer.log("Removed From Geofence Tracker History"));
}

// Delete Geofence tracker history based on LatLng
Future<void> deleteGeoFenceTrackHistory(int id) async {
  final db = await database;
  await db.rawDelete(
      "DELETE FROM " +
          StringValue.user_enter_exit_history +
          " WHERE GeoFenceID = ?",
      [
        '$id'
      ]).whenComplete(
      () => developer.log("Removed From Geofence Tracker History"));
}

// Insert into terminate database
Future<void> insertTerminateGeofence(Geofence_ModalData geofence) async {
  final Database db = await database;
  Map<String, dynamic> value = {
    "Id": geofence.ID,
    "name": geofence.name,
    "lat": geofence.lat,
    "long": geofence.long
  };
  await db.insert(
    StringValue.termnate_location_data,
    value,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Get all Terminate state data
Future<List<Geofence_ModalData>> userTerminateStateLocation() async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query(StringValue.termnate_location_data);
  return List.generate(
    maps.length,
    (i) {
      return Geofence_ModalData(
        ID: maps[i]['ID'],
        name: maps[i]['name'].toString(),
        lat: maps[i]['lat'].toString(),
        long: maps[i]['long'].toString(),
      );
    },
  );
}

// Delete all terminate state location
Future deleteAllTerminateTrackData() async {
  final Database db = await database;
  await db.delete(StringValue.termnate_location_data);
}
