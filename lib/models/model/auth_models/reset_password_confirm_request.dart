class ResetPasswordConfirmRequest {
  final String? email;
  final String? phoneNumber;
  final String verificationCode;
  final String password;
  final String confirmPassword;

  ResetPasswordConfirmRequest({
    this.email,
    this.phoneNumber,
    required this.verificationCode,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phone_number': phoneNumber,
    'verification_code': verificationCode,
    'password': password,
    'confirm_password': confirmPassword,
  };
}
