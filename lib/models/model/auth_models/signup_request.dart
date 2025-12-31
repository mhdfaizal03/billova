class SignupRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String companyName;
  final String phoneNumber;
  final String country;
  final String? dealerCode;

  SignupRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.companyName,
    required this.phoneNumber,
    required this.country,
    this.dealerCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'company_name': companyName,
      'phone_number': phoneNumber,
      'country': country,
      if (dealerCode != null && dealerCode!.isNotEmpty)
        'dealer_code': dealerCode,
    };
  }
}
