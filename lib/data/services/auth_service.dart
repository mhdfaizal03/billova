import 'package:billova/models/model/auth_models/auth_response.dart';
import 'package:billova/models/model/auth_models/login_request.dart';
import 'package:billova/models/model/auth_models/otp_verify_request.dart';
import 'package:billova/models/model/auth_models/resend_otp_request.dart';
import 'package:billova/models/model/auth_models/reset_password_request.dart';
import 'package:billova/models/model/auth_models/reset_password_confirm_request.dart';
import 'package:billova/models/model/auth_models/signup_request.dart';
import 'package:billova/data/services/api_client.dart';

class AuthService {
  static Future<AuthResponse> signUp(SignupRequest request) async {
    try {
      final response = await ApiClient.post(
        '/auth/signup',
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  static Future<AuthResponse> sendSignupOtp(ResendOtpRequest request) async {
    try {
      final response = await ApiClient.post(
        '/auth/signup/resend',
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  static Future<AuthResponse> verifySignupOtp(OtpVerifyRequest request) async {
    try {
      final response = await ApiClient.post(
        '/auth/signup/verify',
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await ApiClient.post(
        '/auth/login',
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  static Future<AuthResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await ApiClient.post(
        '/auth/reset-password',
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  static Future<AuthResponse> confirmPasswordReset(
    ResetPasswordConfirmRequest request,
  ) async {
    try {
      final response = await ApiClient.post(
        '/auth/reset-password',
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }
}
