library backendRootUrl;

String serverRootURL = 'http://hong-kong-bus.herokuapp.com';

void loadConfig(String env) {
  if(env == "PROD") {
    serverRootURL = 'https://hong-kong-bus.herokuapp.com';
  }
  else {
    serverRootURL = 'http://192.168.1.100:5000';
  }
}