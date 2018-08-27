import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hong_kong_bus/domain/NextBusesTimesResult.dart';
import 'package:hong_kong_bus/domain/User.dart';
import 'package:hong_kong_bus/domain/BusTimeToDisplay.dart';
import 'package:hong_kong_bus/widgets/HomePage.dart';
import 'package:http/http.dart' as http;
import 'package:hong_kong_bus/utils/BackendRootURL.dart' as backendRootUrl;

class BusListScreen extends StatefulWidget {
  User connectedUser;
  String configName;

  BusListScreen(this.connectedUser, this.configName);

  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  List<BusTimeToDisplay> myBusTimes;
  NextBusesTimesResult myResult;

  @override
  void initState() {
    print("initState of BusListScreen");
    super.initState();
    this.myResult =
        NextBusesTimesResult("Loading", [BusTimeToDisplay(0, "", "")]);
    print("ready to load NextBusTimes");
    GetBusesTimes(widget.configName).then((result) {
      setState(() {
        this.myResult = result;
      });
    });
//    this.loadUserList().then(widget.setSessionId("toto"));
//    new Future.delayed(const Duration(seconds: 4));
//    Timer(Duration(seconds: 5),() => MyNavigator.goToUsers(context, [User("pi"), User("pi2")]));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.connectedUser.userName == "") {
      return Center(child: Text("You've been logged off"));
      //TODO : find how to navigate to home page
    }
    else if (myResult.lastRefreshTime == "Loading") {
      return Center(
        child: new CircularProgressIndicator(),
      );
    }
    else {
      return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: new EdgeInsets.only(
                        top: 20.0, right: 20.0, bottom: 10.0),
                    child: Text('${myResult.lastRefreshTime}',
                        textAlign: TextAlign.right,
                        style: new TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: myResult.arrivalTimes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          "Bus ${myResult.arrivalTimes[index]
                              .busNumber} - ${myResult.arrivalTimes[index]
                              .arrivalTime} - ${myResult.arrivalTimes[index]
                              .distance}"),
                    );
                  },
                ),
              ),
            ],
          )
      );
    }
  }

  Future<NextBusesTimesResult> GetBusesTimes([String configName = ""]) async {
    NextBusesTimesResult nbtresult;

    String urlIncludingOptionalConfigName;
    if (configName == "") {
      urlIncludingOptionalConfigName =
      '${backendRootUrl.serverRootURL}/nextBusesTimesFor?sessionId=${widget
          .connectedUser.sessionId}';
    }
    else {
      urlIncludingOptionalConfigName =
      '${backendRootUrl.serverRootURL}/nextBusesTimesFor?sessionId=${widget
          .connectedUser.sessionId}&configName=$configName';
    }

    var response = await http.get(urlIncludingOptionalConfigName);

    if(response.statusCode == 401) {
      // Too long inactivity, session must have got pruned, I need a new one
      print(
          "Session ${widget.connectedUser.sessionId} for ${widget.connectedUser
              .userName} was pruned, I need to renew it");
      widget.connectedUser = User("");
      nbtresult = NextBusesTimesResult("user disconnected", [BusTimeToDisplay(0,"user disconnected","user disconnected")]);
    }
    else {
      if (response.statusCode == 200) {
        if (response.body != "[]") {
          nbtresult = NextBusesTimesResult.fromJSON(response.body);
//        var jsonBody = json.decode(response.body);
//        lastRefreshTime = jsonBody["lastRefreshTime"];
//        jsonBody["arrivalTimes"].forEach((busTimeJson) =>
//            busesTimes.add(BusTimeToDisplay.fromJson(busTimeJson)));
        }
        else {
          nbtresult =
              NextBusesTimesResult(
                  "error", [BusTimeToDisplay(-1, "No Bus", "")]);
        }
      }
      else {
        // If that response was not OK, throw an error.
//      throw Exception('Failed to login : ${json.decode(response.body)}');
        nbtresult = NextBusesTimesResult(
            "error", [BusTimeToDisplay(-1, "errorGettingBuses", "-")]);
      }
    }
    print("About to return NextBusTimes, size = ${nbtresult.arrivalTimes
        .length}");
    return nbtresult;
  }

  Future<Null> _handleRefresh() async {
    this.GetBusesTimes().then((result) {
      setState(() {
        this.myResult = result;
      });
    });
  }
}