import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofence_demo/Utils/String_Value.dart';

class Glob {
  static dialog(BuildContext context, String title, String message) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            new FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        );
      },
    );
  }

  static confirmationDialog(BuildContext context, String title, String message,
      Function onYes) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(StringValue.no),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            FlatButton(child: Text(StringValue.yes), onPressed: onYes)
          ],
        );
      },
    );
  }
}
