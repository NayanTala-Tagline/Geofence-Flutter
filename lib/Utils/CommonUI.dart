import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofence_demo/Modal/Geofence_ModalData.dart';
import 'package:geofence_demo/Screen/GeoFence/GeoFenceController.dart';
import 'package:geofence_demo/Utils/Color.dart';
import 'package:geofence_demo/Utils/Glob.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:geofence_demo/Utils/String_Value.dart';
import 'package:get/route_manager.dart';

class RoundedButton extends StatelessWidget {
  final Color circle_color;
  final IconData icons;
  final Color icons_color;
  const RoundedButton({
    Key key,
    this.circle_color,
    this.icons,
    this.icons_color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circle_color,
      ),
      child: Icon(
        icons,
        size: 30,
        color: icons_color,
      ),
    );
  }
}

class TextView extends StatelessWidget {
  final String textname;
  final double fontsize;
  final FontWeight fontweight;
  final Color textcolor;
  final int line_length;
  final TextOverflow overflow;
  final TextAlign textalign;

  const TextView({
    Key key,
    this.textname,
    this.fontweight,
    this.textcolor,
    this.line_length,
    this.overflow,
    this.fontsize,
    this.textalign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      textname,
      style: TextStyle(
          fontSize: fontsize, fontWeight: fontweight, color: textcolor),
      maxLines: line_length,
      overflow: overflow,
      textAlign: textalign,
    );
  }
}

class RadiusButton extends StatelessWidget {
  final double height;
  final Color boxcolor;
  final String textname;
  final double fontsize;
  final Color textcolor;
  const RadiusButton({
    Key key,
    this.height,
    this.boxcolor,
    this.textcolor,
    this.fontsize,
    this.textname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: boxcolor ?? blue,
      ),
      child: TextView(
        textname: textname,
        fontsize: fontsize ?? 15,
        fontweight: FontWeight.bold,
        textcolor: textcolor ?? white,
        line_length: 1,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.center,
      ),
    );
  }
}

class ErrorName extends StatelessWidget {
  final String error_name;
  final bool isvisible;
  const ErrorName({
    Key key,
    this.error_name,
    this.isvisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isvisible,
      child: TextView(
        textname: error_name,
        fontsize: 12,
        fontweight: FontWeight.normal,
        textcolor: red,
        line_length: 1,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
      ),
    );
  }
}

class TextFilled extends StatelessWidget {
  final FocusNode currentfocus;
  final FocusNode nextFocusNode;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final String text;
  final TextInputType keyboardtype;
  final bool isfocus;
  final bool isenable;
  final BuildContext context;
  const TextFilled({
    Key key,
    this.currentfocus,
    this.nextFocusNode,
    this.textInputAction,
    this.controller,
    this.text,
    this.keyboardtype,
    this.isenable,
    this.isfocus,
    this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          padding: EdgeInsets.only(left: 10),
          height: 40,
          decoration: BoxDecoration(
            color: white,
            border: Border.all(color: black),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            enabled: isenable,
            focusNode: currentfocus,
            onEditingComplete: () => isfocus
                ? FocusScope.of(context).unfocus()
                : FocusScope.of(context).requestFocus(nextFocusNode),
            textInputAction: textInputAction,
            controller: controller,
            cursorColor: Colors.black,
            keyboardType: keyboardtype,
            decoration: InputDecoration(
              fillColor: white,
              hintText: text,
              border: InputBorder.none,
            ),
          )),
    );
  }
}

class CardViewData extends StatelessWidget {
  final Geofence_ModalData data;
  final int index;
  final Function onPressed;
  const CardViewData({
    Key key,
    this.data,
    this.index,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Container(
          padding: EdgeInsets.all(5),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    textname: data.name,
                    fontsize: 15,
                    fontweight: FontWeight.w600,
                  ),
                  SizedBox(height: 5),
                  TextView(
                      textname: StringValue.lat + ": " + data.lat,
                      fontsize: 12,
                      fontweight: FontWeight.w400),
                  SizedBox(height: 5),
                  TextView(
                      textname: StringValue.long + ": " + data.long,
                      fontsize: 12,
                      fontweight: FontWeight.w400),
                  SizedBox(height: 5),
                  TextView(
                      textname: StringValue.radius + ": " + data.radius,
                      fontsize: 12,
                      fontweight: FontWeight.w400),
                  SizedBox(height: 5),
                ],
              ),
              GetBuilder<GeoFenceGetController>(
                builder: (geoFenceGetController) {
                  return GestureDetector(
                    child: ImageIcon(
                      AssetImage(StringValue.deleteIcon),
                      color: red,
                    ),
                    onTap: () {
                      Glob.confirmationDialog(
                        context,
                        StringValue.delete_geofence,
                        StringValue.geofence_delete_message,
                        () async {
                          Navigator.pop(context);
                          await geoFenceGetController.deleteGeofences(
                            data: data,
                            index: index,
                          );
                        },
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
