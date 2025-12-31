import 'package:billova/utils/constants/colors.dart';
import 'package:billova/view/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billova',
      theme: ThemeData(
        textTheme: GoogleFonts.aBeeZeeTextTheme(),
        scaffoldBackgroundColor: AppColors().creamcolor,
        colorScheme: .fromSeed(seedColor: AppColors().creamcolor),
      ),
      home: SplashScreen(),
    );
  }
}
