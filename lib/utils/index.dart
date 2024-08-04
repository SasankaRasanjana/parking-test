import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/intl.dart' show DateFormat;

class PageLoader {
  static show(BuildContext pageContext, [bool show = true]) {
    // app in active state
    if (!show) {
      return;
    }
    showDialog(
      barrierColor: Colors.white60,
      barrierDismissible: false,
      context: pageContext,
      builder: (BuildContext context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(),
          )),
    );
  }

  static hide(BuildContext pageContext, [bool show = true]) {
    if (!show) {
      return;
    }
    Navigator.of(pageContext, rootNavigator: true).pop();
  }
}

extension BuildContextExtension on BuildContext {
  show([bool show = true]) {
    // app in active state
    if (!show) {
      return;
    }
    showDialog(
      barrierColor: Colors.white60,
      barrierDismissible: false,
      context: this,
      builder: (BuildContext context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(),
          )),
    );
  }

  hide([bool show = true]) {
    if (!show) {
      return;
    }
    Navigator.of(this, rootNavigator: true).pop();
  }

  showSnackBar(String? message,
      [Function? completion, Duration duration = const Duration(seconds: 4)]) {
    if (message != null) {
      final snackBar = SnackBar(
        content: Text(message),
        duration: duration,
      );
      ScaffoldMessenger.of(this).showSnackBar(snackBar).closed.then((value) {
        if (completion != null) {
          completion();
        }
      });
    }
  }

  navigator(BuildContext context, Widget child, {bool shouldBack = true}) {
    if (!shouldBack) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => child));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => child));
  }
}

extension DateTimeExtension on DateTime {
  String formatDate() {
    DateFormat formatter = DateFormat('yyyy/MM/dd');
    return formatter.format(toLocal());
  }

  String formatTime() {
    DateFormat formatter = DateFormat('HH:mm a');
    return formatter.format(toLocal());
  }
}

String formatDate(DateTime date, [bool form = false]) {
  if (form) {
    return DateFormat("y-MM-dd").format(date);
  }
  return DateFormat.yMMMd().format(date);
}

TimeOfDay parseTime(String timeStr) {
  timeStr = timeStr.replaceAll(RegExp('\\s[A|P]M'), '');
  List<String> timeParts = timeStr.split(":");
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
  return time;
}

String formatTime(TimeOfDay time, [bool form = false]) {
  DateTime dateTime = DateTime(0, 0, 0, time.hour, time.minute, 0, 0);

  if (form) {
    return DateFormat.Hms().format(dateTime);
  }
  return DateFormat.jm().format(dateTime);
}
