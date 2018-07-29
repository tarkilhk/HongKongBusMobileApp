import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hong_kong_bus/utils/BackendRootURL.dart' as backendRootUrl;


class User {
  String userName;
  String sessionId;

  User(String myUserName, {String mySessionId: ""}) {
    this.userName = myUserName;
    this.sessionId = mySessionId;
  }

  Future<String> loginAndReturnSessionId() async {
//    var response = await http.get("http://192.168.1.115:8080/login?userName=pi");
    var response = await http.get("${backendRootUrl.serverRootURL}/login?userName=${this.userName}");

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return (response.body);
    } else {
      // If that response was not OK, throw an error.
//      throw Exception('Failed to login : ${json.decode(response.body)}');
      return "error";
    }
  }

  bool isConnected() {
    return (this.sessionId != "");
  }

  Future<List<String>> getConfigNames() async {
    List<String> myConfigNames = [];
    var response = await http.get('${backendRootUrl.serverRootURL}/user/configNames?sessionId=$sessionId');

    if (response.statusCode == 200) {
      myConfigNames.clear();
      json.decode(response.body).forEach((configName) => myConfigNames.add(configName));
    }
    else {
      // If that response was not OK, throw an error.
//      throw Exception('Failed to login : ${json.decode(response.body)}');
      myConfigNames = ["ConfigLoadError"];
    }
    print("about to return userListFromBackend, size = ${myConfigNames.length}");
    return myConfigNames;
  }
}