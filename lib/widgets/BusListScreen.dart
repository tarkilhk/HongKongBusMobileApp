import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hong_kong_bus/domain/User.dart';
import 'package:hong_kong_bus/domain/BusTimeToDisplay.dart';
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

  @override
  void initState () {
    print("initState of UserListScreen");
    super.initState();
    this.myBusTimes = [];
    print("ready to load userList");
    GetBusesTimes(widget.configName).then((result) {
      setState(() {
        this.myBusTimes = result;
      });
    });
//    this.loadUserList().then(widget.setSessionId("toto"));
//    new Future.delayed(const Duration(seconds: 4));
//    Timer(Duration(seconds: 5),() => MyNavigator.goToUsers(context, [User("pi"), User("pi2")]));
  }

  @override
  Widget build(BuildContext context) {
    if (this.myBusTimes.isEmpty) {
      return Center(
        child: new CircularProgressIndicator(),
      );
    }
    else {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: myBusTimes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  "Bus ${myBusTimes[index].busNumber} - ${myBusTimes[index]
                      .arrivalTime} - ${myBusTimes[index].distance}"),
            );
          },
        ),
      );
    }
  }

  Future<List<BusTimeToDisplay>> GetBusesTimes([String configName=""]) async {
    List<BusTimeToDisplay> busesTimes = [];
    String urlIncludingOptionalConfigName;
    if(configName == "") {
      urlIncludingOptionalConfigName = '${backendRootUrl.serverRootURL}/nextBusesTimesFor?sessionId=${widget.connectedUser.sessionId}';
    }
    else {
      urlIncludingOptionalConfigName = '${backendRootUrl.serverRootURL}/nextBusesTimesFor?sessionId=${widget.connectedUser.sessionId}&configName=$configName';
    }

    var response = await http.get(urlIncludingOptionalConfigName);

    if (response.statusCode == 200) {
      busesTimes.clear();
      if(response.body != "[]") {
        json.decode(response.body).forEach((busTimeJson) =>
            busesTimes.add(BusTimeToDisplay.fromJson(busTimeJson)));
      }
      else {
        busesTimes = [BusTimeToDisplay(-1, "No Bus", "")];
      }
    }
    else {
      // If that response was not OK, throw an error.
//      throw Exception('Failed to login : ${json.decode(response.body)}');
      busesTimes = [BusTimeToDisplay(-1, "errorGettingBuses", "-")];
    }
    print("About to return userListFromBackend, size = ${busesTimes.length}");
    return busesTimes;
  }

  Future<Null> _handleRefresh() async {
    this.GetBusesTimes().then((result) {
      setState(() {
        this.myBusTimes = result;
      });
    });
  }
}
