import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hong_kong_bus/domain/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hong_kong_bus/utils/BackendRootURL.dart' as backendRootUrl;

class UserListScreen extends StatefulWidget {
  // Declare a field that holds the UserConfig
  Function setConnectedUser;

  UserListScreen(this.setConnectedUser);

  @override
  _UserListScreenState createState() => new _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> loadedUserList;

  @override
  void initState () {
    print("initState of UserListScreen");
    super.initState();
    this.loadedUserList = [User("LOADING")];
    print("ready to load userList");
    loadUserListFromBackend().then((result) {
      setState(() {
        this.loadedUserList = result;
      });
    });
//    this.loadUserList().then(widget.setSessionId("toto"));
//    new Future.delayed(const Duration(seconds: 4));
//    Timer(Duration(seconds: 5),() => MyNavigator.goToUsers(context, [User("pi"), User("pi2")]));
  }

  @override
  Widget build(BuildContext context) {
    // Use the userList to create our UI
    return Scaffold(
      appBar: AppBar(
        title: Text("Who are you ?"),
      ),
      body: ListView.builder(
        itemCount: loadedUserList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(loadedUserList[index].userName),
            // When a user taps on the ListTile, navigate to the ConfigListScreen.
            // Notice that we're not only creating a ConfigListScreen, we're
            // also passing the current user through to it!
            onTap: () {
              setState(() {
                _tapOnUserName(loadedUserList[index].userName);
                print("I am ${loadedUserList[index].userName}");
                widget.setConnectedUser(User(loadedUserList[index].userName));
              });
            },
          );
        },
      ),
    );
  }

  Future<List<User>> loadUserListFromBackend() async {
    List<User> userListFromBackend = [];
    var response = await http.get('${backendRootUrl.serverRootURL}/users');

    if (response.statusCode == 200) {
      this.loadedUserList.clear();
      json.decode(response.body).forEach((userName) => userListFromBackend.add(User(userName)));
    }
    else {
      // If that response was not OK, throw an error.
//      throw Exception('Failed to login : ${json.decode(response.body)}');
      userListFromBackend = [User("CouldntLoadUsers")];
    }
    print("about to return userListFromBackend, size = ${userListFromBackend.length}");
    return userListFromBackend;
  }

  _tapOnUserName(String tappedUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', tappedUserName);
  }
}

