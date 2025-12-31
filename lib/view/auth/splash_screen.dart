// import 'package:billova/utils/local_Storage/token_storage.dart';
// import 'package:billova/view/auth/select_auth_page.dart';
// import 'package:billova/view/home/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationCtr;
//   late Animation<double> _scaleAnim;

//   @override
//   void initState() {
//     super.initState();

//     _animationCtr = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _scaleAnim = Tween<double>(
//       begin: 2.5,
//       end: 2.5,
//     ).animate(CurvedAnimation(parent: _animationCtr, curve: Curves.easeOut));

//     _animationCtr.forward();

//     _navigate();
//   }

//   /// 🔐 TOKEN CHECK + NAVIGATION
//   Future<void> _navigate() async {
//     await Future.delayed(const Duration(milliseconds: 1500));

//     final token = await TokenStorage.getToken(); // ✅ FIX

//     if (!mounted) return;

//     if (token != null && token.isNotEmpty) {
//       /// ✅ USER LOGGED IN
//       Get.offAll(
//         () => HomeScreen(),
//         transition: Transition.fade,
//         duration: const Duration(milliseconds: 1000),
//       );
//     } else {
//       /// ❌ NOT LOGGED IN
//       Get.offAll(
//         () => SelectAuthPage(),
//         transition: Transition.fade,
//         duration: const Duration(milliseconds: 1000),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _animationCtr.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Hero(
//           tag: 'logo',
//           child: AnimatedBuilder(
//             animation: _scaleAnim,
//             builder: (context, child) {
//               return Transform.scale(scale: _scaleAnim.value, child: child);
//             },
//             child: Image.asset('assets/images/billova_logo.png', width: 180),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/network_issues/no_internet_page.dart';
import 'package:billova/view/auth/select_auth_page.dart';
import 'package:billova/view/home/home_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationCtr;
  late Animation<double> _scaleAnim;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _navigated = false; // 🔐 prevents double navigation

  @override
  void initState() {
    super.initState();

    /// 🎞️ LOGO ANIMATION
    _animationCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = Tween<double>(
      begin: 0.1,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _animationCtr, curve: Curves.easeOut));

    _animationCtr.forward();

    /// ⏳ Delay for splash + initial check
    Future.delayed(const Duration(milliseconds: 1500), () {
      _checkInternetAndNavigate();
    });

    /// 📡 LISTEN FOR INTERNET RETURN
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        _checkInternetAndNavigate();
      }
    });
  }

  /// 🌐 INTERNET + 🔐 TOKEN CHECK
  Future<void> _checkInternetAndNavigate() async {
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (_navigated) return;

      final connectivity = await Connectivity().checkConnectivity();
      if (!mounted) return;

      /// ❌ NO INTERNET
      // if (connectivity.contains(ConnectivityResult.none)) {
      //   _navigated = true;
      //   Get.offAll(() => const NoInternetPage(), transition: Transition.fade);
      //   return;
      // }

      /// 🔐 TOKEN CHECK
      final token = await TokenStorage.getToken();
      if (!mounted) return;

      _navigated = true;

      if (token != null && token.isNotEmpty) {
        /// ✅ USER LOGGED IN
        Get.offAll(
          () => HomeScreen(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 800),
        );
      } else {
        /// ❌ NOT LOGGED IN
        Get.offAll(
          () => const SelectAuthPage(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 800),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationCtr.dispose();
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) {
                  return Transform.scale(scale: _scaleAnim.value, child: child);
                },
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/billova_logo.png',
                    width: 180,
                  ),
                ),
              ),
              // CircularProgressIndicator(strokeWidth: 1.8),
            ],
          ),
        ),
      ),
    );
  }
}
