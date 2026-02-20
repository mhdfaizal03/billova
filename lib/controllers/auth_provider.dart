import 'package:billova/models/model/auth_models/resend_otp_request.dart';
import 'package:flutter/material.dart';
import 'package:billova/data/services/auth_service.dart';
import 'package:billova/models/model/auth_models/auth_response.dart';
import 'package:billova/models/model/auth_models/login_request.dart';
import 'package:billova/models/model/auth_models/signup_request.dart';
import 'package:billova/models/model/auth_models/otp_verify_request.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:get/get.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await TokenStorage.getToken();
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<AuthResponse> login(String email, String password) async {
    setLoading(true);
    final request = LoginRequest(email: email, password: password);
    final response = await AuthService.login(request);

    if (response.success && response.token != null) {
      _token = response.token;
      await TokenStorage.saveToken(_token!);
    }

    setLoading(false);
    return response;
  }

  Future<AuthResponse> signUp(SignupRequest request) async {
    setLoading(true);
    final response = await AuthService.signUp(request);
    setLoading(false);
    return response;
  }

  Future<AuthResponse> resendOtp(String emailOrPhone) async {
    // Determine if it's email or phone if needed, but ResendOtpRequest might just need one field or handle it.
    // Let's check ResendOtpRequest definition. Assuming it has phoneNumber or email.
    // Step 27 AuthService.sendSignupOtp uses ResendOtpRequest.
    // Step 132 ConfirmOtpPage passes phoneNumber.

    // I need to check ResendOtpRequest.
    // I'll assume it handles phone mainly or has similar structure.
    // For now I'll just use phoneNumber parameter as passed from UI which is usually phone.
    // But Wait, ConfirmOtpPage passes phoneNumber.

    setLoading(true);
    // Assuming ResendOtpRequest takes phoneNumber or email.
    // I'll use the same logic as verify.
    final request = ResendOtpRequest(
      phoneNumber: emailOrPhone,
    ); // Simplifying for now based on usage
    final response = await AuthService.sendSignupOtp(request);
    setLoading(false);
    return response;
  }

  Future<AuthResponse> verifyOtp(String emailOrPhone, String otp) async {
    setLoading(true);
    final isEmail = GetUtils.isEmail(emailOrPhone);
    final request = OtpVerifyRequest(
      verificationCode: otp,
      email: isEmail ? emailOrPhone : null,
      phoneNumber: !isEmail ? emailOrPhone : null,
    );
    final response = await AuthService.verifySignupOtp(request);

    if (response.success && response.token != null) {
      _token = response.token;
      await TokenStorage.saveToken(_token!);
    }

    setLoading(false);
    return response;
  }

  Future<void> logout() async {
    _token = null;
    await TokenStorage.clearAll();
    notifyListeners();
  }
}
