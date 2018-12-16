import 'dart:convert';
import 'package:hong_kong_bus/domain/BusTimeToDisplay.dart';

class NextBusesTimesResult {
  var arrivalTimes = <BusTimeToDisplay>[];
  String lastRefreshTime;
  bool isLoaded;

  NextBusesTimesResult.fromJSON(String arrivalTimesInJSON) {
    var jsonBody = json.decode(arrivalTimesInJSON);
    lastRefreshTime = "Last refreshed at ${jsonBody["lastRefreshTime"]}";
    isLoaded = jsonBody["isLoaded"];
    jsonBody["arrivalTimes"].forEach((busTimeJson) =>
        arrivalTimes.add(BusTimeToDisplay.fromJson(busTimeJson)));
  }

  NextBusesTimesResult(this.lastRefreshTime, this.arrivalTimes);
}