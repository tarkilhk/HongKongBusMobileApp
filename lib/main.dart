import 'package:flutter/material.dart';
import 'package:hong_kong_bus/widgets/HomePage.dart';
import 'package:hong_kong_bus/utils/BackendRootURL.dart' as backendRootUrl;


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override initState() {
    super.initState();
    backendRootUrl.loadConfig("PROD","us");
//    backendRootUrl.loadConfig("DEV","whatever");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hong Kong Bus',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}