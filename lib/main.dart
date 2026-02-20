import 'package:billova/controllers/auth_provider.dart';
import 'package:billova/controllers/category_provider.dart';
import 'package:billova/controllers/product_provider.dart';
import 'package:billova/controllers/tax_provider.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/view/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

late Size mq;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => TaxProvider()),
      ],
      child: GetMaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'Billova',
        theme: ThemeData(
          textTheme: GoogleFonts.aBeeZeeTextTheme(),
          scaffoldBackgroundColor: AppColors().creamcolor,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors().creamcolor),
        ),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 400),
        builder: (context, child) {
          mq = MediaQuery.of(context).size;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child,
          );
        },
        home: SplashScreen(),
      ),
    );
  }
}
