// lib/utils/widgets/custom_home_drawer.dart
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:billova/main.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/custom_dialog_box.dart';
import 'package:billova/view/auth/select_auth_page.dart';
import 'package:billova/view/drawer_items/dashboard/dashboard_page.dart';
import 'package:billova/view/drawer_items/items_page.dart';
import 'package:billova/view/drawer_items/reciepts_page.dart';
import 'package:billova/view/drawer_items/sales_page.dart';
import 'package:billova/view/drawer_items/settings_page.dart';
import 'package:billova/view/drawer_items/support_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Drawer buildGlassDrawer(BuildContext context) {
  final colors = AppColors();

  return Drawer(
    width: mq.width * .65,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: SafeArea(
        child: Container(
          height: mq.height,
          color: Colors.white.withOpacity(.7),
          child: SingleChildScrollView(
            child: ConstrainBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Profile Tile ---
                  Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.vertical,
                    children:
                        [
                              sh30,
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: colors.creamcolor.withOpacity(.7),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: colors.browcolor,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    "MS Restaurant",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text("POS 1"),
                                ),
                              ),
                              sh20,
                              _drawerSection("MANAGEMENT"),

                              _glassTile(
                                Icons.bar_chart_rounded,
                                () {
                                  Get.back();
                                  Get.to(() => const SalesPage());
                                },
                                "Sales Report",
                                colors,
                              ),
                              _glassTile(
                                Icons.inventory_2_rounded,
                                () {
                                  Get.back();
                                  Get.to(() => const RecieptsPage());
                                },
                                "Receipts",
                                colors,
                              ),
                              _glassTile(
                                Icons.category_rounded,
                                () {
                                  Get.back();
                                  Get.to(() => const ItemsPage());
                                },
                                "Items",
                                colors,
                              ),
                              _glassTile(
                                Icons.tune_rounded,
                                () {
                                  Get.back();
                                  Get.to(() => const SettingsPage());
                                },
                                "Settings",
                                colors,
                              ),

                              const SizedBox(height: 10),
                            ]
                            .animate(interval: 50.ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: -0.1),
                  ),
                  Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.vertical,
                    children:
                        [
                              _drawerSection("DASHBOARD"),
                              _glassTile(
                                Icons.dashboard_customize_rounded,
                                () {
                                  Get.back();
                                  Get.to(() => const DashboardPage());
                                },
                                "Dashboard",
                                colors,
                              ),

                              _glassTile(
                                Icons.support_agent_rounded,
                                () {
                                  Get.back();
                                  Get.to(() => const SupportPage());
                                },
                                "Support",
                                colors,
                              ),
                              _glassTile(
                                Icons.logout_rounded,
                                () {
                                  Get.back();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CustomDialogBox(
                                        title: "Logout",
                                        content:
                                            "Are you sure you want to logout from the app?",
                                        saveText: "Logout",
                                        onSave: () async {
                                          await TokenStorage.clearAll();

                                          Get.offAll(
                                            () => const SelectAuthPage(),
                                            transition: Transition.fadeIn,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                "Logout",
                                colors,
                                isLogout: true,
                              ),
                            ]
                            .animate(interval: 50.ms, delay: 200.ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: -0.1),
                  ),
                  // Align(
                  //   alignment: Alignment.bottomCenter,
                  //   child: Text(
                  //     "Billova v1.0.0",
                  //     style: TextStyle(color: Colors.grey[700]),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _drawerSection(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.black38,
      ),
    ),
  );
}

Widget _glassTile(
  IconData icon,
  Function()? onTap,
  String title,
  AppColors colors, {
  bool isLogout = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 35, bottom: 5),
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: isLogout
            ? Colors.red.withOpacity(.09)
            : colors.creamcolor.withOpacity(.55),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(10),
        ),
      ),
      child: Center(
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: isLogout ? Colors.red : colors.browcolor),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLogout ? Colors.red : Colors.black87,
            ),
          ),
        ),
      ),
    ),
  );
}
