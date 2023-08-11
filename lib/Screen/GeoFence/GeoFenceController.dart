import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geofence_demo/Screen/GoogleMap/GoogleMapController.dart';
import 'package:geofence_demo/Utils/String_Value.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

import '../../Modal/Geofence_ModalData.dart';
import '../../Utils/Glob.dart';
import '../../database/dbConnect.dart';
import 'dart:developer' as developer;

class GeoFenceGetController extends GetxController {
  List<Geofence_ModalData> geofence = [];
  bool isname = false;
  bool islat = false;
  bool islong = false;
  bool isradius = false;

  var ed_geofence_name = TextEditingController();
  var ed_lat = TextEditingController();
  var ed_long = TextEditingController();
  var ed_radius = TextEditingController();

  var database;
  bool isDataValidate = false;
  bool isLatValidate = false;

  GoogleMapGetController googleMapGetController = Get.find();

  @override
  void onInit() {
    super.onInit();
    getGeoFenceData();
  }

  @override
  void onClose() {
    super.onClose();
    ed_geofence_name.dispose();
    ed_lat.dispose();
    ed_long.dispose();
    ed_radius.dispose();
  }

  void getGeoFenceData() async {
    await initDB();
    await geofencelist().then((value) {
      if (value != null && value.length != 0) geofence.addAll(value);
      update();
    });
  }

  void addGeofenceData({Geofence_ModalData geofenceData}) async {
    await insertGeofence(geofenceData).whenComplete(() {
      getAllGeofenceData();
      print("__________Add Geo Fence____________");
      dismissDialog();
    });
  }

  void getAllGeofenceData() async {
    await initDB();
    await geofencelist().then((value) {
      if (geofence.isNotEmpty) geofence.clear();
      geofence.addAll(value);
      update();
    });
  }

  void isValidate() {
    if (ed_geofence_name.text.isEmpty) {
      isname = true;
    } else if (ed_lat.text.isEmpty) {
      if (ed_geofence_name.text.isEmpty) {
        isname = true;
      } else {
        isname = false;
      }
      islat = true;
    } else if (ed_long.text.isEmpty) {
      if (ed_geofence_name.text.isEmpty) {
        isname = true;
      } else {
        isname = false;
      }
      if (ed_lat.text.isEmpty) {
        islat = true;
      } else {
        islat = false;
      }
      islong = true;
    } else if (ed_radius.text.isEmpty) {
      if (ed_geofence_name.text.isEmpty) {
        isname = true;
      } else {
        isname = false;
      }
      if (ed_lat.text.isEmpty) {
        islat = true;
      } else {
        islat = false;
      }
      if (ed_long.text.isEmpty) {
        islong = true;
      } else {
        islong = false;
      }
      isradius = true;
    } else {
      isname = false;
      islat = false;
      islong = false;
      isradius = false;
    }
    if (!isname && !islat && !islong && !isradius) {
      isDataValidate = true;
    } else {
      isDataValidate = false;
    }
    update();
  }

  void dismissDialog() {
    isDataValidate = false;
    isLatValidate = false;
    isname = false;
    islat = false;
    islong = false;
    isradius = false;

    ed_geofence_name.clear();
    ed_lat.clear();
    ed_long.clear();
    ed_radius.clear();
    update();
  }

  Future<void> deleteGeofences({int index, Geofence_ModalData data}) async {
    // Delete Geofence Data
    await deletegeofence(data.ID).whenComplete(() {
      getAllGeofenceData();
    });

    developer.log(index.toString() + " ID");

    // Delete Geofence History data associated with above deleted geofence
    await deleteGeoFenceTrackHistory(data.ID);
  }

  Future<void> isValidateLatLng({BuildContext context}) async {
    if (isDataValidate) {
      await placemarkFromCoordinates(double.parse(ed_lat.text.toString()),
              double.parse(ed_long.text.toString()))
          .then((value) async {
        if (value.length != 0) {
          await user_geofence(ed_geofence_name.text).then((value) {
            if (value.length == 0) {
              isLatValidate = true;
              update();
            } else {
              isLatValidate = false;
              update();
              Glob.dialog(
                  context, StringValue.error, StringValue.geofence_name_error);
            }
          });
        } else {
          isLatValidate = false;
          update();
          Glob.dialog(context, StringValue.error, StringValue.lat_long_wrong);
        }
      }).catchError((onError) {
        isLatValidate = false;
        update();
        Glob.dialog(context, StringValue.error, StringValue.lat_long_wrong);
      });
    }
  }

  void setCurrent_lat_long() {
    ed_lat.text = googleMapGetController.latLng.latitude.toString();
    ed_long.text = googleMapGetController.latLng.longitude.toString();
    update();
  }
}
