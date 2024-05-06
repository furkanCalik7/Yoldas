// RUN flutter run --realease for production
const bool isProduction = bool.fromEnvironment('dart.vm.product');

const String debugApiUrl = "http://10.0.2.2:8000";
//const String debugApiUrl = "http://localhost:8000";
const String productionApiUrl = "http://161.35.202.231:8000";

const String deployedApiUrl = "http://161.35.202.231:8000";

const String API_URL = debugApiUrl;
