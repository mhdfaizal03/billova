import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  static Stream<bool> internetStream() {
    return Connectivity().onConnectivityChanged.map(
      (r) => r.isNotEmpty && !r.contains(ConnectivityResult.none),
    );
  }
}
