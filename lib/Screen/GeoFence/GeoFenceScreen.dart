import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofence_demo/Modal/Geofence_ModalData.dart';
import 'package:geofence_demo/Screen/GeoFence/GeoFenceController.dart';
import 'package:geofence_demo/Utils/Color.dart';
import 'package:geofence_demo/Utils/CommonUI.dart';
import 'package:geofence_demo/Utils/String_Value.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Utils/CommonUI.dart';
import 'package:get/get.dart';

class GeoFenceData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GeoFenceData_state();
}

class GeoFenceData_state extends State<GeoFenceData> {
  FocusNode geofence_name_FocusNode = new FocusNode();
  FocusNode lattitude_FocusNode = new FocusNode();
  FocusNode long_FocusNode = new FocusNode();
  FocusNode radius_FocusNode = new FocusNode();

  GeoFenceGetController geoFenceGetController =
      Get.put(GeoFenceGetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(StringValue.geofence), centerTitle: true),
      body: GetBuilder<GeoFenceGetController>(
        init: GeoFenceGetController(),
        builder: (controller) {
          return Container(
            child: controller.geofence.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0.0),
                    itemCount: controller.geofence.length,
                    itemBuilder: (context, index) => CardViewData(
                      data: controller.geofence[index],
                      index: index,
                      onPressed: () {
                        Get.back();
                        controller.googleMapGetController.changecameraposition(
                          updateLatlng: LatLng(
                            double.parse(controller.geofence[index].lat),
                            double.parse(controller.geofence[index].long),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: TextView(
                      textname: StringValue.no_data_available,
                      fontsize: 15,
                      fontweight: FontWeight.bold,
                      textcolor: black,
                      line_length: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                    ),
                  ),
          );
        },
      ),
      floatingActionButton: InkWell(
        onTap: () {
          geoFenceGetController.setCurrent_lat_long();
          addGeoFenceDialog();
        },
        child: RoundedButton(
          circle_color: blue,
          icons: Icons.add,
          icons_color: white,
        ),
      ),
    );
  }

  Future addGeoFenceDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return GetBuilder<GeoFenceGetController>(
            builder: (geoFenceGetController) {
              return AlertDialog(
                title: Center(
                  child: TextView(
                      textname: StringValue.add_geofence,
                      fontsize: 22,
                      fontweight: FontWeight.bold,
                      textcolor: black,
                      line_length: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center),
                ),
                content: Wrap(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextView(
                              textname: StringValue.geofence_name,
                              fontsize: 15,
                              fontweight: FontWeight.normal,
                              textcolor: black,
                              line_length: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left),
                          spaceView(5),
                          TextFilled(
                            currentfocus: geofence_name_FocusNode,
                            nextFocusNode: lattitude_FocusNode,
                            textInputAction: TextInputAction.next,
                            controller: geoFenceGetController.ed_geofence_name,
                            context: context,
                            text: StringValue.geofence_name,
                            isfocus: false,
                            isenable: true,
                            keyboardtype: TextInputType.text,
                          ),
                          spaceView(5),
                          ErrorName(
                            error_name: StringValue.error_name,
                            isvisible: geoFenceGetController.isname,
                          ),
                          spaceView(15),
                          TextView(
                              textname: StringValue.lat,
                              fontsize: 15,
                              fontweight: FontWeight.normal,
                              textcolor: black,
                              line_length: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left),
                          spaceView(5),
                          TextFilled(
                            currentfocus: lattitude_FocusNode,
                            nextFocusNode: long_FocusNode,
                            textInputAction: TextInputAction.next,
                            controller: geoFenceGetController.ed_lat,
                            context: context,
                            text: StringValue.lat,
                            isfocus: false,
                            isenable: true,
                            keyboardtype: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                          ),
                          spaceView(5),
                          ErrorName(
                            error_name: StringValue.error_name,
                            isvisible: geoFenceGetController.islat,
                          ),
                          spaceView(15),
                          TextView(
                              textname: StringValue.long,
                              fontsize: 15,
                              fontweight: FontWeight.normal,
                              textcolor: black,
                              line_length: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left),
                          spaceView(5),
                          TextFilled(
                            currentfocus: long_FocusNode,
                            nextFocusNode: radius_FocusNode,
                            textInputAction: TextInputAction.next,
                            controller: geoFenceGetController.ed_long,
                            context: context,
                            text: StringValue.long,
                            isfocus: false,
                            isenable: true,
                            keyboardtype: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                          ),
                          spaceView(5),
                          ErrorName(
                            error_name: StringValue.error_long,
                            isvisible: geoFenceGetController.islong,
                          ),
                          spaceView(15),
                          TextView(
                              textname: StringValue.radius,
                              fontsize: 15,
                              fontweight: FontWeight.normal,
                              textcolor: black,
                              line_length: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left),
                          spaceView(5),
                          TextFilled(
                            currentfocus: radius_FocusNode,
                            nextFocusNode: radius_FocusNode,
                            textInputAction: TextInputAction.done,
                            controller: geoFenceGetController.ed_radius,
                            context: context,
                            text: StringValue.radius,
                            isfocus: true,
                            isenable: true,
                            keyboardtype: TextInputType.number,
                          ),
                          spaceView(5),
                          ErrorName(
                            error_name: StringValue.error_radius,
                            isvisible: geoFenceGetController.isradius,
                          ),
                          spaceView(15),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    geoFenceGetController.dismissDialog();
                                  },
                                  child: RadiusButton(
                                    boxcolor: red,
                                    textname: StringValue.cancel,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    geoFenceGetController.isValidate();
                                    await geoFenceGetController
                                        .isValidateLatLng(context: context)
                                        .whenComplete(() {
                                      if (geoFenceGetController
                                              .isDataValidate &&
                                          geoFenceGetController.isLatValidate) {
                                        geoFenceGetController.addGeofenceData(
                                          geofenceData: new Geofence_ModalData(
                                            name: geoFenceGetController
                                                .ed_geofence_name.text
                                                .toLowerCase(),
                                            lat: geoFenceGetController
                                                .ed_lat.text,
                                            long: geoFenceGetController
                                                .ed_long.text,
                                            radius: geoFenceGetController
                                                .ed_radius.text,
                                          ),
                                        );
                                        geoFenceGetController.dismissDialog();
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  child: RadiusButton(
                                    boxcolor: green,
                                    textname: StringValue.add,
                                  ),
                                ),
                              )
                            ],
                          ),
                          spaceView(10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Widget spaceView(double height) => SizedBox(height: height);
}
