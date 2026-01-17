import 'dart:async';

import 'package:billova/main.dart';
import 'package:billova/models/model/auth_models/otp_verify_request.dart';
import 'package:billova/models/model/auth_models/resend_otp_request.dart';
import 'package:billova/models/services/auth_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/view/auth/login_page.dart';
import 'package:billova/view/auth/select_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmOtpPage extends StatefulWidget {
  final String phoneNumber;

  const ConfirmOtpPage({super.key, required this.phoneNumber});

  @override
  State<ConfirmOtpPage> createState() => _ConfirmOtpPageState();
}

class _ConfirmOtpPageState extends State<ConfirmOtpPage> {
  bool isVerifyingOtp = false;
  bool isSendingOtp = false;

  int otpTimer = 0;
  Timer? _otpTimer;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get otpCode => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    _otpTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  /// ---------------- VERIFY OTP ----------------
  Future<void> verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (isVerifyingOtp) return;

    if (otpCode.length != 6) {
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: 'Please enter 6-digit OTP',
      );
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Please enter 6-digit OTP')));
      return;
    }

    setState(() => isVerifyingOtp = true);

    Future.delayed(Duration(milliseconds: 2000), () async {
      final response = await AuthService.verifySignupOtp(
        OtpVerifyRequest(
          phoneNumber: widget.phoneNumber,
          verificationCode: otpCode,
        ),
      );

      if (!mounted) return;
      setState(() => isVerifyingOtp = false);

      /// ✅ BACKEND CONFIRMS VIA MESSAGE
      if (response.message.toLowerCase().contains(
        'Verification successful'.toLowerCase(),
      )) {
        CustomSnackBar.show(
          color: AppColors().browcolor,
          context: context,
          message: 'OTP verified successfully',
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('OTP verified successfully')),
        // );
        Get.offAll(() => LoginPage());
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
    });
  }

  /// ---------------- RESEND OTP ----------------
  Future<void> resendOtp() async {
    if (isSendingOtp || otpTimer > 0) return;

    setState(() => isSendingOtp = true);

    final response = await AuthService.sendSignupOtp(
      ResendOtpRequest(phoneNumber: widget.phoneNumber),
    );

    if (!mounted) return;
    setState(() => isSendingOtp = false);

    if (response.message.toLowerCase().contains('sent')) {
      startOtpTimer();
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: 'OTP resent',
      );
    } else {
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: response.message,
      );
    }
  }

  void startOtpTimer() {
    otpTimer = 60;
    _otpTimer?.cancel();

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer == 0) {
        timer.cancel();
      } else {
        setState(() => otpTimer--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: CustomBackButton(
                onTap: () => Get.offAll(() => SelectAuthPage()),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enter OTP',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'We have sent a 6-digit code to\n${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 45,
                        height: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors().browcolor.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (v) => _onChanged(v, index),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    child: CustomButtons(
                      text: isVerifyingOtp
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                              'Verify OTP',
                              style: TextStyle(fontSize: mq.width * .040),
                            ),
                      onPressed: isVerifyingOtp ? null : verifyOtp,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: otpTimer > 0 ? null : resendOtp,
                    child: Text(
                      otpTimer > 0
                          ? 'Resend OTP in ${otpTimer}s'
                          : 'Resend OTP',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
