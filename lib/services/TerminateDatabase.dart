import 'package:geofence_demo/Modal/Geofence_ModalData.dart';
import 'package:geofence_demo/database/dbConnect.dart';
import 'package:geofence_demo/main.dart';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class TerminateDatabase {
  Future getGeofenceModalData(List<Map<String, dynamic>> geofence) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Geofence_ModalData> geofenceData = [];

    geofence.forEach((element) {
      developer.log(element.toString(), name: "Terminated saved data");
      geofenceData.add(new Geofence_ModalData(
        ID: int.parse(element['$id'].toString()),
        name: element['$name'].toString(),
        lat: element['$lat'].toString(),
        long: element['$long'].toString(),
        startTime: element['$startTime'].toString(),
        exitTime: element['$exitTime'].toString(),
        CurrentEnterTime: element['$currentEnterTime'].toString(),
        CurrentExitTime: element['$currentExitTime'].toString(),
      ));
    });

    int temp = prefs.getInt('temp');
    String activeIdentifier = prefs.getString(identifier) ?? "Not available";
    bool isAvailable = prefs.getBool(isUserAvailableInGeofence) ?? false;
    int activeId = prefs.getInt(id) ?? 1000;

    if (temp != null) {
      developer.log(temp.toString(),
          name: "Number of execution happened in terminate state");
    }
    developer.log(activeIdentifier.toString(),
        name: "Identifier From Terminate");
    developer.log(isAvailable.toString(), name: "isAvailable from Terminate");
    developer.log(activeId.toString(), name: "ids from Terminate state");

    // Save data to database
    saveGeofenceTerminateData(
      data: geofenceData,
      identifier: activeIdentifier,
      id: activeId,
    );
  }

  // Add Geofence data to identifier database
  Future saveGeofenceTerminateData({
    List<Geofence_ModalData> data,
    String identifier,
    int id,
  }) async {
    await initDB();
    // List<Geofence_ModalData> isUser = [];
    List<Geofence_ModalData> userTrackHistoryData = [];
    DateTime startDate;
    DateTime endDate;

    //isUser = await isUserEnter(identifier, "");
    userTrackHistoryData = await user_history();

    data.forEach((terminateData) async {
      DateTime terminateDateTime = getDateTime(terminateData.CurrentEnterTime);
      userTrackHistoryData.forEach((element) async {
        // if (terminateData.name == element.name) {
        startDate = getDateTime(element.CurrentEnterTime);
        if (element.CurrentExitTime.isEmpty ||
            element.CurrentExitTime == null) {
          endDate = DateTime.now();
        } else {
          endDate = getDateTime(element.CurrentExitTime);
        }

        bool start = startDate.isBefore(terminateDateTime);
        bool end = endDate.isAfter(terminateDateTime);
        if (start && end) {
          var geofenceData = Geofence_ModalData(
            ID: element.ID,
            name: element.name,
            lat: terminateData.lat,
            long: terminateData.long,
            startTime: terminateData.startTime,
          );
          await insert_user_Location_history(geofenceData);
        }
        // }
      });
    });

    // if (isUser.isNotEmpty) {
    //   data.forEach((element) async {
    //     var geofenceData = Geofence_ModalData(
    //       ID: element.ID,
    //       name: element.name,
    //       lat: element.lat,
    //       long: element.long,
    //       startTime: element.startTime,
    //     );
    //     await insert_user_Location_history(geofenceData);
    //   });
    // } else {
    //   developer.log(
    //       "This Geofence data is not available in user_enter_exit_history table");
    // }

    // developer.log("-----------------------------");
    // developer.log(element.name.toString());
    // developer.log(element.CurrentEnterTime.toString());
    // developer.log(element.CurrentExitTime.toString());
    // developer.log(element.enterTime.toString());
    // developer.log(element.exitTime.toString());
    // developer.log("-----------------------------");
  }

  DateTime getDateTime(String dateTime) {
    List<String> main = dateTime.split(' ');
    List<String> date = main[0].split('-');
    List<String> time = main[1].split(':');
    List<String> seconds = time[2].split('.');

    return DateTime(
      int.parse(date[0]), // Year
      int.parse(date[1]), // Month
      int.parse(date[2]), // Day
      int.parse(time[0]), // Hour
      int.parse(time[1]), // Minute
      int.parse(seconds[0]), // Seconds
    );
  }
}
