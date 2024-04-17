// RUN flutter run --realease for production
const bool isProduction = bool.fromEnvironment('dart.vm.product');

// const String debugApiUrl = "http://10.0.2.2:8000";
const String debugApiUrl = "http://localhost:8000";
const String productionApiUrl = "http://68.183.79.22:8000";

const String API_URL = isProduction ? productionApiUrl : debugApiUrl;