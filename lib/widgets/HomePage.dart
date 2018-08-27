import 'package:flutter/material.dart';
import 'package:hong_kong_bus/domain/User.dart';
import 'package:hong_kong_bus/widgets/BusListScreen.dart';
import 'package:hong_kong_bus/widgets/ConfigListScreen.dart';
import 'package:hong_kong_bus/widgets/SplashScreen.dart';
import 'package:hong_kong_bus/widgets/UserListScreen.dart';
import 'package:hong_kong_bus/widgets/UserLoginLoadingScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User connectedUser = User("init");
  String configName = "";

  void _setConnectedUser(User updatedConnectedUser) {
    setState(() {
      this.connectedUser = updatedConnectedUser;
//      this.connectedUser.login()      TODO : can we login here directly ?
    });
  }

  void _setConfigName(String updatedConfigName) {
    setState(() {
      this.configName = updatedConfigName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: configName==""?Text('Hello ${connectedUser.userName}'):Text('Hello ${connectedUser.userName} - $configName'),
    ),
    body: widgetPicker(),
    );
  }

  Widget widgetPicker() {
    if(connectedUser.userName == "init") {
      print("userName = init");
      // Display SplashScreen (SplashScreen should load from Preferences)
      return SplashScreen(_setConnectedUser);
    }
    else if(connectedUser.userName == "") {
      print("userName empty, need to load list from backend");
      // Display SplashScreen (SplashScreen should load from Preferences)
      return UserListScreen(_setConnectedUser);
    }
    else if(! connectedUser.isConnected()) {
      print("userName ${connectedUser.userName} needs to login");
      return UserLoginLoadingScreen(connectedUser, _setConnectedUser);
    }
    else {
      // app is already logged in to the backend and has a sessionId
      if (configName == "") {
        // Display configChooser - should load config list from API
        print("userName ${connectedUser.userName} logged in with session id ${connectedUser.sessionId}");
        return ConfigListScreen(connectedUser, _setConfigName);
      }
      else {
        // Display BusList
        print("I need to display Bus List");
        return BusListScreen(this.connectedUser,this.configName);
      }
    }
  }
}