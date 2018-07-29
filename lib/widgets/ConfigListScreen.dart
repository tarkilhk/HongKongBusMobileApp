import 'package:flutter/material.dart';
import 'package:hong_kong_bus/domain/User.dart';

class ConfigListScreen extends StatefulWidget {
  final Function setConfigName;
  final User connectedUser;

  ConfigListScreen(this.connectedUser, this.setConfigName);

  @override
  _ConfigListScreenState createState() => new _ConfigListScreenState();
}

class _ConfigListScreenState extends State<ConfigListScreen> {
  List<String> configNames;

  _ConfigListScreenState();

  @override
  void initState () {
    super.initState();
    this.configNames = ["LOADING"];

    widget.connectedUser.getConfigNames().then((result) {
      setState(() {
        this.configNames = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the userList to create our UI
    return Scaffold(
      appBar: AppBar(
        title: Text("What do you want to see ?"),
      ),
      body: ListView.builder(
        itemCount: configNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(configNames[index]),
            // When a user taps on the ListTile, navigate to the ConfigListScreen.
            // Notice that we're not only creating a ConfigListScreen, we're
            // also passing the current user through to it!
            onTap: () {
              setState(() {
                _tapOnConfigName(configNames[index]);
                print("I want ${configNames[index]}");
              });
            },
          );
        },
      ),
    );
  }


  _tapOnConfigName(String tappedConfigName) {
    setState(() {
      widget.setConfigName(tappedConfigName);
    });
  }
}