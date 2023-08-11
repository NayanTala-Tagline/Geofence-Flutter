import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';

import '../../Modal/Geofence_ModalData.dart';
import '../../database/dbConnect.dart';

class TrackingHistoryGetController extends GetxController {
  // Tracking History Data in Tracking history screen
  List<Geofence_ModalData> userhistorylist = [];

  // 15 min tracking location data within geofence
  List<Geofence_ModalData> userlocationlist = [];

  @override
  void onInit() {
    super.onInit();
    getTrackHistory();
  }

  // Get All Tracking History screen Data
  void getTrackHistory() async {
    print("object");
    List<Geofence_ModalData> list = [];
    await initDB();
    list = await user_history();
    userhistorylist = list;
    update();
  }

  // Get All Veiew details data of selected Geofence
  Future getUserLocation(int id) async {
    await initDB();
    List<Geofence_ModalData> list = [];
    list = await user_location(id);
    userlocationlist = list;
    update();
  }

  // Delete Tracking Data of a geofence
  Future<void> deleteTrackHistory(
      {Geofence_ModalData geofenceHistory, int index}) async {
    print(geofenceHistory.ID.toString() + " ID");
    await deleteTrackerhistory(geofenceHistory.ID).whenComplete(() {
      userhistorylist.removeAt(index);
      update();
    });
  }

  getTimeDifference(String currentEnterTime, String currentExitTime) {
    final date_formate = new DateFormat('yyyy-MM-dd hh:mm:ss');
    var startTime = date_formate.parse(currentEnterTime);
    var currentTime = currentExitTime.isNotEmpty
        ? date_formate.parse(currentExitTime)
        : date_formate.parse(DateTime.now().toString());
    var diff_min = currentTime.difference(startTime).inMinutes;
    var diff_sec = currentTime.difference(startTime).inSeconds;
    var diff_hours = currentTime.difference(startTime).inHours;
    var time = "";

    if (diff_sec < 60) {
      time = diff_sec.toString() + " Seconds ago";
    } else if (diff_min < 60) {
      time = diff_min.toString() + " Minutes ago";
    } else if (diff_hours < 12) {
      time = diff_hours.toString() + " Hours ago";
    } else {
      final date_formate_ = new DateFormat('yyyy-MM-dd');
      var date1 = date_formate_.parse(currentEnterTime);
      var date2 = date_formate_.parse(currentExitTime);
      var diff_inday = date2.difference(date1).inDays;
      time = diff_inday.toString() + " Day ago";
    }
    return time;
  }
}
