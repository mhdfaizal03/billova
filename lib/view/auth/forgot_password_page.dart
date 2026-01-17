import 'package:billova/main.dart';
import 'package:billova/models/model/auth_models/reset_password_request.dart';
import 'package:billova/models/services/auth_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtr = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() => isLoading = true);

    final response = await AuthService.resetPassword(
      ResetPasswordRequest(email: emailCtr.text.trim()),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (response.success) {
      CustomSnackBar.show(
        context: context,
        color: AppColors().browcolor,
        message: 'Password reset instructions have been sent to your email.',
      );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //       'Password reset instructions have been sent to your email.',
      //     ),
      //   ),
      // );

      Navigator.pop(context); // back to login
    } else {
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: response.message,
      );
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainBox(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: mq.height * 0.1),

                        /// LOGO
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/images/billova_logo.png',
                            height: mq.height * 0.20,
                          ),
                        ),

                        /// TITLE
                        const Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        sh10,

                        const Text(
                          'Enter your registered email address.\nWe will send you instructions to reset your password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),

                        sh30,

                        /// EMAIL FIELD
                        CustomField(
                          text: 'Email',
                          controller: emailCtr,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),

                        sh30,

                        /// SUBMIT BUTTON
                        CustomButtons(
                          text: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Text(
                                  'Sent Reset Link',
                                  style: TextStyle(fontSize: mq.width * .040),
                                ),
                          onPressed: isLoading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(top: 10, left: 10, child: CustomBackButton()),
            ],
          ),
        ),
      ),
    );
  }
}
