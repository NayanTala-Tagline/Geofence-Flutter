import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofence_demo/Modal/Geofence_ModalData.dart';
import 'package:geofence_demo/Screen/Tracking/TrackingHistoryController.dart';
import 'package:geofence_demo/Utils/Color.dart';
import 'package:geofence_demo/Utils/CommonUI.dart';
import 'package:geofence_demo/Utils/Glob.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:geofence_demo/Utils/String_Value.dart';

class TrackingHistory extends StatefulWidget {
  @override
  _TrackingHistoryState createState() => _TrackingHistoryState();
}

class _TrackingHistoryState extends State<TrackingHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringValue.track_history), centerTitle: true),
      body: GetBuilder<TrackingHistoryGetController>(
        init: TrackingHistoryGetController(),
        builder: (controller) {
          return controller.userhistorylist.isNotEmpty
              ? RefreshIndicator(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0.0),
                    itemCount: controller.userhistorylist.length,
                    itemBuilder: (context, index) => CardViewTrackHistory(
                      geofence_history: controller.userhistorylist[index],
                      index: index,
                    ),
                  ),
                  onRefresh: () async {
                       controller.userhistorylist.clear();
                       controller. getTrackHistory();
                  })
              : RefreshIndicator(
                  child: Center(
                    child: TextView(
                      textname: StringValue.no_data_available,
                      fontsize: 15,
                      fontweight: FontWeight.w500,
                      textcolor: Colors.black54,
                      line_length: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                    ),
                  ),
                  onRefresh: () async {
                    controller.getTrackHistory();
                  });
        },
      ),
    );
  }
}

// Card view desing of
class CardViewTrackHistory extends StatelessWidget {
  final Geofence_ModalData geofence_history;
  final int index;
  const CardViewTrackHistory({
    Key key,
    this.geofence_history,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackingHistoryGetController>(
      builder: (controller) {
        return Card(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextView(
                      textname: geofence_history.name,
                      fontsize: 15,
                      fontweight: FontWeight.bold,
                    ),
                    Text(
                      controller.getTimeDifference(geofence_history.CurrentEnterTime,geofence_history.CurrentExitTime),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DateTimeLayout(
                        textvalue1: StringValue.enter_date + ": ",
                        fontWeight: FontWeight.w400,
                        textvalue2: StringValue.exit_date + ": "),
                    SizedBox(width: 5),
                    DateTimeLayout(
                      textvalue1: geofence_history.enterTime,
                      fontWeight: FontWeight.w500,
                      textvalue2: geofence_history.exitTime.isEmpty
                          ? StringValue.na
                          : geofence_history.exitTime,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 30,
                      margin: EdgeInsets.only(top: 10),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: blue),
                        ),
                        color: blue,
                        elevation: 0,
                        onPressed: () async {
                          // Get all History Data from database first
                          await controller
                              .getUserLocation(geofence_history.ID)
                              .whenComplete(
                            () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return TrackingDetailsPopUp(
                                    index: index,
                                    geofence_history: geofence_history,
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: TextView(
                            textname: StringValue.view_details,
                            textcolor: white),
                      ),
                    ),
                    GestureDetector(
                      child: ImageIcon(
                        AssetImage(StringValue.deleteIcon),
                        size: 20,
                        color: red,
                      ),
                      onTap: () {
                        // Delete Geofence History Data
                        Glob.confirmationDialog(
                          context,
                          StringValue.delete,
                          StringValue.delete_history_recoed,
                          () async {
                            await controller
                                .deleteTrackHistory(
                                    geofenceHistory: geofence_history,
                                    index: index)
                                .whenComplete(
                                  () => Navigator.pop(context),
                                );
                          },
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Track History Date & Time screen design
class DateTimeLayout extends StatelessWidget {
  final String textvalue1;
  final FontWeight fontWeight;
  final String textvalue2;

  const DateTimeLayout(
      {Key key, this.textvalue1, this.textvalue2, this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(textname: textvalue1, fontsize: 12, fontweight: fontWeight),
        SizedBox(height: 5),
        TextView(textname: textvalue2, fontsize: 12, fontweight: fontWeight),
      ],
    );
  }
}

class DateTimeLocationLayout extends StatelessWidget {
  final String title1;
  final FontWeight fontWeight;
  final String title2;
  final String title3;
  const DateTimeLocationLayout(
      {Key key, this.title1, this.fontWeight, this.title2, this.title3})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(textname: title1, fontsize: 12, fontweight: fontWeight),
        SizedBox(height: 5),
        TextView(textname: title2, fontsize: 12, fontweight: fontWeight),
        SizedBox(height: 5),
        TextView(textname: title3, fontsize: 12, fontweight: fontWeight),
      ],
    );
  }
}

// Tracking details list item design
class TrackingDetailsListItem extends StatelessWidget {
  final Geofence_ModalData locationList;
  const TrackingDetailsListItem({Key key, this.locationList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DateTimeLocationLayout(
            title1: StringValue.date_and_time + ": ",
            fontWeight: FontWeight.w400,
            title2: StringValue.lat + ": ",
            title3: StringValue.long + ": ",
          ),
          SizedBox(width: 5),
          DateTimeLocationLayout(
            title1: locationList.startTime,
            fontWeight: FontWeight.w400,
            title2: locationList.lat,
            title3: locationList.long,
          ),
        ],
      ),
    );
  }
}

// Tracking details Pop up
class TrackingDetailsPopUp extends StatelessWidget {
  final int index;
  final Geofence_ModalData geofence_history;
  const TrackingDetailsPopUp({Key key, this.index, this.geofence_history})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackingHistoryGetController>(
      builder: (controller) {
        return StatefulBuilder(builder: (context, dialog_setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(
                    textname: geofence_history.name,
                    fontsize: 15,
                    fontweight: FontWeight.bold),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 22, maxWidth: 22),
                  child: MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    elevation: 0,
                    color: red,
                    child: Icon(Icons.clear, size: 18, color: Colors.white),
                    padding: EdgeInsets.all(2),
                    shape: CircleBorder(),
                  ),
                )
              ],
            ),
            content: Container(
              child: SingleChildScrollView(
                child: controller.userlocationlist.length == 0
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 15, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            DateTimeLayout(
                                textvalue1: StringValue.enter_date + ": ",
                                fontWeight: FontWeight.w400,
                                textvalue2: StringValue.exit_date + ": "),
                            SizedBox(
                              width: 5,
                            ),
                            DateTimeLayout(
                              textvalue1: geofence_history.enterTime,
                              fontWeight: FontWeight.w500,
                              textvalue2: geofence_history.exitTime.isEmpty
                                  ? StringValue.na
                                  : geofence_history.exitTime,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: List<Widget>.generate(
                          controller.userlocationlist.length,
                          (index) => Container(
                            child: TrackingDetailsListItem(
                              locationList: controller.userlocationlist[index],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        });
      },
    );
  }
}
