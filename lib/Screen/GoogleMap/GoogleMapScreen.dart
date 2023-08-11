import 'package:flutter/material.dart';
import 'package:geofence_demo/Screen/GeoFence/GeoFenceScreen.dart';
import 'package:geofence_demo/Screen/GoogleMap/GoogleMapController.dart';
import 'package:geofence_demo/Screen/Tracking/TrackingHistoryScreen.dart';
import 'package:geofence_demo/Utils/CommonUI.dart';
import 'package:geofence_demo/Utils/String_Value.dart';
import 'package:geofence_demo/database/dbConnect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Googlemap extends StatefulWidget {
  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<Googlemap> {
  Location location = Location();
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(StringValue.googlemap), centerTitle: true),
      body: GetBuilder<GoogleMapGetController>(
        init: GoogleMapGetController(),
        builder: (googleMapController) {
          return Stack(
            children: [
              if (googleMapController.currentPositionOfUser != null) ...{
                Stack(
                  children: [
                    GoogleMap(
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: googleMapController.latLng,
                        zoom: googleMapController.zoom,
                      ),
                      markers: googleMapController.markers,
                      circles: googleMapController.circles ?? Set.from([]),
                      onMapCreated: (GoogleMapController controller) async {
                        //  _completer.complete(controller);
                        googleMapController.setGoogleMapController(controller);
                        googleMapController.getCircles();
                        // Stream of user's current Location
                        location.onLocationChanged.listen((l) async {
                          // Get curent location
                          googleMapController.changeInLocation(
                            latLong: LatLng(l.latitude, l.longitude),
                          );
                          // Update the marker
                          googleMapController.addMarker();
                          googleMapController.changecameraposition(
                            updateLatlng: LatLng(l.latitude, l.longitude),
                          );
                        });
                      },
                    ),
                    Positioned(
                      right: 20.0,
                      bottom: screenSize / 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          color: Colors.black,
                          onPressed: () async {
                            googleMapController.changecameraposition(
                              updateLatlng: googleMapController.latLng,
                            );
                          },
                          icon: Icon(Icons.my_location),
                        ),
                      ),
                    )
                  ],
                )
              } else if (googleMapController.hasAllPermissions !=
                      HasAllPermissions.YES &&
                  googleMapController.hasAllPermissions !=
                      HasAllPermissions.ASK) ...{
                Center(child: Text('No access to location'))
              } else ...{
                Center(child: CircularProgressIndicator())
              },
              Positioned(
                right: 20.0,
                left: 20.0,
                bottom: screenSize / 20,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => GeoFenceData()).whenComplete(
                              () => googleMapController.addGeoFenceData());
                        },
                        child: RadiusButton(textname: StringValue.geofence),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await deleteAllTerminateTrackData();
                          Get.to(() => TrackingHistory()).whenComplete(
                              () => googleMapController.addGeoFenceData());
                        },
                        child:
                            RadiusButton(textname: StringValue.track_history),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
