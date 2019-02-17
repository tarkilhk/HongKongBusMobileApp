import 'dart:async';
import 'dart:io';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hong_kong_bus/domain/NextBusesTimesResult.dart';
import 'package:hong_kong_bus/domain/User.dart';
import 'package:hong_kong_bus/domain/BusTimeToDisplay.dart';
//import 'package:hong_kong_bus/widgets/HomePage.dart';
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
        NextBusesTimesResult("Loading", [BusTimeToDisplay("0", "", "")]);
    print("ready to load NextBusTimes");
    GetBusesTimes(widget.configName).then((result) {
      setState(() {
        this.myResult = result;
      });
    });
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
                      title: Text(FormatLine(myResult.arrivalTimes[index])
                          ),
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
    int counterOfAttemptsToGETnextFor = 0;
    bool INeedToTryToLoadBusTimes = true;

    if(configName != "") {
//      urlIncludingOptionalConfigName =
//      '${backendRootUrl.serverRootURL}/nextBusesTimesFor?sessionId=${widget
//          .connectedUser.sessionId}&configName=$configName';
      var response = await http.post('${backendRootUrl.serverRootURL}/sessions/changeConfigName',headers: {"Accept":"application/json"}, body: {"sessionId":widget.connectedUser.sessionId,"configName":configName} );
      if(response.statusCode!=200) {
        return NextBusesTimesResult(
            "error", [BusTimeToDisplay("-1", "Cannot changeConfigName", "-")]);
      }
    }

    while(INeedToTryToLoadBusTimes) {
      INeedToTryToLoadBusTimes = false;
      var response = await http.get('${backendRootUrl.serverRootURL}/busTimes/nextFor?sessionId=${widget
          .connectedUser.sessionId}');

      if(response.statusCode == 401) {
        // Too long inactivity, session must have got pruned, I need a new one
        print(
            "Session ${widget.connectedUser.sessionId} for ${widget.connectedUser
                .userName} was pruned, I need to renew it");
        widget.connectedUser = User("");
        nbtresult = NextBusesTimesResult("user disconnected", [BusTimeToDisplay("-1","user disconnected","user disconnected")]);
      }
      else {
        if (response.statusCode == 200) {
          if(NextBusesTimesResult.fromJSON(response.body).isLoaded) {
            if (NextBusesTimesResult
                .fromJSON(response.body)
                .arrivalTimes
                .length != 0) {
              nbtresult = NextBusesTimesResult.fromJSON(response.body);
            }
            else {
              nbtresult =
                  NextBusesTimesResult(
                      "error", [BusTimeToDisplay("-1", "No Bus", "")]);
            }
          }
          else {
            counterOfAttemptsToGETnextFor += 1;
            if(counterOfAttemptsToGETnextFor <= 3) {
              print("Still not loaded going to wait for 5s : Loop #$counterOfAttemptsToGETnextFor");
              //TODO : do not do a sleep on the main thread : should be sending a message back to upstream components, retry loading buses from there
              sleep(const Duration(seconds:5));
              INeedToTryToLoadBusTimes = true;
            }
          }
        }
        else {
          // If that response was not OK, throw an error.
//      throw Exception('Failed to login : ${json.decode(response.body)}');
          nbtresult = NextBusesTimesResult(
              "error", [BusTimeToDisplay("-1", "errorGettingBuses", "-")]);
        }
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

String FormatLine(BusTimeToDisplay arrivalTime) {
  if (arrivalTime.busNumber != -1) {
    return "Bus ${arrivalTime.busNumber} - ${arrivalTime
        .arrivalTime} - ${arrivalTime.distance}";
  }
  else {
    return arrivalTime.arrivalTime;
  }
}