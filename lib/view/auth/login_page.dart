import 'package:billova/main.dart';
import 'package:billova/models/model/auth_models/login_request.dart';
import 'package:billova/models/services/auth_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/view/auth/forgot_password_page.dart';
import 'package:billova/view/auth/select_store_page.dart';
import 'package:billova/view/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();

  bool pass = true;
  bool isLoggingIn = false;

  @override
  void dispose() {
    emailCtr.dispose();
    passwordCtr.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (isLoggingIn) return;

    setState(() => isLoggingIn = true);

    final response = await AuthService.login(
      LoginRequest(
        email: emailCtr.text.trim(),
        password: passwordCtr.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => isLoggingIn = false);

    /// 🔹 CASE 1: MULTIPLE STORES FOUND
    if (response.multipleStores && response.stores.isNotEmpty) {
      Get.offAll(
        () => SelectStorePage(
          stores: response.stores,
          email: emailCtr.text.trim(),
          password: passwordCtr.text.trim(),
        ),
        transition: Transition.fadeIn,
      );
      return;
    }

    /// 🔹 CASE 2: SINGLE STORE / NORMAL LOGIN
    if (response.token != null && response.token!.isNotEmpty) {
      await TokenStorage.saveToken(response.token!);

      Get.offAll(() => HomeScreen(), transition: Transition.fadeIn);

      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: response.message,
      );
    } else {
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: response.message.isNotEmpty
            ? response.message
            : 'Login failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon = pass ? Icons.visibility : Icons.visibility_off;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: ConstrainBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/billova_logo.png',
                                fit: BoxFit.cover,
                                height: mq.height * 0.30,
                              ),
                            ),

                            /// EMAIL
                            Flex(
                              direction: Axis.vertical,
                              children: [
                                CustomField(
                                  text: 'Email',
                                  controller: emailCtr,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Email required';
                                    }
                                    if (!GetUtils.isEmail(v)) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                ),

                                sh10,

                                /// PASSWORD
                                CustomField(
                                  text: 'Password',
                                  controller: passwordCtr,
                                  obscure: pass,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Password required';
                                    }
                                    return null;
                                  },
                                  suffix: GestureDetector(
                                    onTap: () => setState(() => pass = !pass),
                                    child: Icon(icon),
                                  ),
                                ),
                                sh60,

                                /// LOGIN BUTTON
                                Hero(
                                  tag: 'logbtn',
                                  child: isLoggingIn
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : CustomButtons(
                                          text: isLoggingIn
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: mq.width * .040,
                                                  ),
                                                ),
                                          onPressed: isLoggingIn
                                              ? null
                                              : _login,
                                        ),
                                ),

                                sh10,

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Forgot password navigation
                                      Get.to(() => ForgotPasswordPage());
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(top: 10, left: 10, child: CustomBackButton()),
        ],
      ),
    );
  }
}
