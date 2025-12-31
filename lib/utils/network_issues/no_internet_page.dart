import 'package:app_settings/app_settings.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/view/auth/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  Future<void> _retryConnection() async {
    final result = await Connectivity().checkConnectivity();

    if (!result.contains(ConnectivityResult.none)) {
      /// ✅ INTERNET BACK → GO TO SPLASH
      Get.offAll(() => const SplashScreen());
    } else {
      /// ❌ STILL NO INTERNET
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: Get.context!,
        message: 'No Internet Connection.\nPlease enable Wi-Fi or Mobile Data',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 90,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 20),

              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                'Please check your Wi-Fi or mobile data\nand try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  /// 🔹 Open Internet settings
                  AppSettings.openAppSettingsPanel(
                    AppSettingsPanelType.internetConnectivity,
                  );
                },
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _retryConnection,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
