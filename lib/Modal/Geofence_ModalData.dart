class Geofence_ModalData {
  String name = "";
  String lat = "";
  String long = "";
  String radius = "";
  String enterTime = "";
  String exitTime = "";
  String startTime = "";
  int ID = 0;
  int GeoFenceID = 0;
  String CurrentEnterTime;
  String CurrentExitTime;


  Geofence_ModalData({
    this.name,
    this.lat,
    this.long,
    this.radius,
    this.enterTime,
    this.exitTime,
    this.startTime,
    this.ID,
    this.GeoFenceID,
    this.CurrentEnterTime,
    this.CurrentExitTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lat': lat,
      'long': long,
      'radius': radius,
    };
  }

  Map<String, dynamic> userLocationtoMap() {
    return {
      'ID': ID,
      'name': name,
      'lat': lat,
      'long': long,
      'startTime': startTime,
    };
  }

  Map<String, dynamic> enter_exit_toMap() {
    return {
      'name': name,
      'GeoFenceID': GeoFenceID,
      'enterTime': enterTime,
      'exitTime': exitTime,
      'CurrentEnterTime' :CurrentEnterTime,
      'CurrentExitTime' :CurrentExitTime,
    };
  }
}
