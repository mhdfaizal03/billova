import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:billova/models/model/auth_models/auth_response.dart';
import 'package:billova/models/model/auth_models/login_request.dart';
import 'package:billova/models/model/auth_models/otp_verify_request.dart';
import 'package:billova/models/model/auth_models/resend_otp_request.dart';
import 'package:billova/models/model/auth_models/reset_password_request.dart';
import 'package:billova/models/model/auth_models/signup_request.dart';

class AuthService {
  /// ---------------- BASE CONFIG ----------------
  static const String _baseUrl =
      'https://billova-backend.onrender.com/api/auth';

  static const Duration _timeout = Duration(seconds: 8);

  static Map<String, String> _headers() => {'Content-Type': 'application/json'};

  /// ---------------- SIGN UP ----------------
  static Future<AuthResponse> signUp(SignupRequest request) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/signup'),
            headers: _headers(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _parseResponse(res);
    } on TimeoutException {
      return _timeoutError();
    } on SocketException {
      return _noInternetError();
    } catch (e) {
      return _unknownError(e);
    }
  }

  /// ---------------- SEND / RESEND SIGNUP OTP ----------------
  /// (Used for both first send & resend based on backend)
  static Future<AuthResponse> sendSignupOtp(ResendOtpRequest request) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/signup/resend'),
            headers: _headers(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _parseResponse(res);
    } on TimeoutException {
      return _timeoutError();
    } on SocketException {
      return _noInternetError();
    } catch (e) {
      return _unknownError(e);
    }
  }

  /// ---------------- VERIFY SIGNUP OTP ----------------
  static Future<AuthResponse> verifySignupOtp(OtpVerifyRequest request) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/signup/verify'),
            headers: _headers(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _parseResponse(res);
    } on TimeoutException {
      return _timeoutError();
    } on SocketException {
      return _noInternetError();
    } catch (e) {
      return _unknownError(e);
    }
  }

  /// ---------------- LOGIN ----------------
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: _headers(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _parseResponse(res);
    } on TimeoutException {
      return _timeoutError();
    } on SocketException {
      return _noInternetError();
    } catch (e) {
      return _unknownError(e);
    }
  }

  /// ---------------- LOGIN ----------------
  static Future<AuthResponse> multipleLogin(LoginRequest request) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: _headers(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _parseResponse(res);
    } on TimeoutException {
      return _timeoutError();
    } on SocketException {
      return _noInternetError();
    } catch (e) {
      return _unknownError(e);
    }
  }

  /// ---------------- RESET PASSWORD ----------------
  static Future<AuthResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/reset-password'),
            headers: _headers(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _parseResponse(res);
    } on TimeoutException {
      return _timeoutError();
    } on SocketException {
      return _noInternetError();
    } catch (e) {
      return _unknownError(e);
    }
  }

  /// ---------------- RESPONSE PARSER ----------------
  static AuthResponse _parseResponse(http.Response res) {
    try {
      final body = res.body.isNotEmpty
          ? jsonDecode(res.body)
          : <String, dynamic>{};

      return AuthResponse.fromJson(body);
    } catch (_) {
      return AuthResponse(success: false, message: 'Invalid server response');
    }
  }

  /// ---------------- ERROR HELPERS ----------------
  static AuthResponse _timeoutError() {
    return AuthResponse(
      success: false,
      message: 'Request timeout. Please try again.',
    );
  }

  static AuthResponse _noInternetError() {
    return AuthResponse(success: false, message: 'No internet connection.');
  }

  static AuthResponse _unknownError(Object e) {
    return AuthResponse(success: false, message: e.toString());
  }
}
