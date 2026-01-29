import 'package:billova/models/model/auth_models/login_request.dart';
import 'package:billova/models/services/auth_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/view/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/model/auth_models/auth_response.dart';

class SelectStorePage extends StatefulWidget {
  final List<StoreModel> stores;
  final String email;
  final String password;

  const SelectStorePage({
    super.key,
    required this.stores,
    required this.email,
    required this.password,
  });

  @override
  State<SelectStorePage> createState() => _SelectStorePageState();
}

class _SelectStorePageState extends State<SelectStorePage> {
  int? _loadingIndex; // which store is loading

  Future<void> _selectStore(StoreModel store, int index) async {
    if (_loadingIndex != null) return; // 🔒 prevent double tap

    setState(() => _loadingIndex = index);

    try {
      /// 🔐 LOGIN WITH STORE ID
      final AuthResponse res = await AuthService.multipleLogin(
        LoginRequest(
          email: widget.email,
          password: widget.password,
          storeId: store.id,
        ),
      );

      if (res.token != null && res.token!.isNotEmpty) {
        /// ✅ SAVE TOKEN
        await TokenStorage.saveToken(res.token!);

        /// ✅ SAVE STORE
        await TokenStorage.saveSelectedStore(store.id);

        /// 🚀 GO TO HOME
        Get.offAll(
          () => const HomeScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 350),
        );
      } else {
        throw Exception('Invalid login response');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingIndex = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }

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
        itemCount: widget.stores.length,
        itemBuilder: (_, index) {
          final store = widget.stores[index];
          final isLoading = _loadingIndex == index;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _loadingIndex == null || isLoading ? 1 : 0.5,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                enabled: !isLoading,
                title: Text(
                  store.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: isLoading ? null : () => _selectStore(store, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
