import 'package:billova/models/model/auth_models/login_request.dart';
import 'package:billova/models/services/auth_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/view/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/model/auth_models/auth_response.dart';

class SelectStorePage extends StatelessWidget {
  final List<StoreModel> stores;

  /// 🔐 REQUIRED to re-login
  final String email;
  final String password;

  const SelectStorePage({
    super.key,
    required this.stores,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Store'),
        backgroundColor: AppColors().browcolor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (_, index) {
          final store = stores[index];

          return Card(
            child: ListTile(
              title: Text(store.name),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                try {
                  /// 🔐 LOGIN AGAIN WITH STORE ID
                  final AuthResponse res = await AuthService.multipleLogin(
                    LoginRequest(
                      email: email,
                      password: password,
                      storeId: store.id,
                    ),
                  );

                  if (res.token != null && res.token!.isNotEmpty) {
                    /// ✅ SAVE NEW TOKEN
                    await TokenStorage.saveToken(res.token!);

                    /// ✅ SAVE SELECTED STORE
                    await TokenStorage.saveSelectedStore(store.id);

                    /// 🚀 GO HOME
                    Get.offAll(
                      () => const HomeScreen(),
                      transition: Transition.rightToLeftWithFade,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
