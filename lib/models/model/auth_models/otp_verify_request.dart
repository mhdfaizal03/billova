class OtpVerifyRequest {
  final String verificationCode;
  final String? email;
  final String? phoneNumber;

  OtpVerifyRequest({
    required this.verificationCode,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'verification_code': verificationCode,
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phone_number': phoneNumber,
  };
}
