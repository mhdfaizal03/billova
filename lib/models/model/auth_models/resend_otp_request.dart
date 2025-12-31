class ResendOtpRequest {
  final String? email;
  final String? phoneNumber;

  ResendOtpRequest({this.email, this.phoneNumber});

  Map<String, dynamic> toJson() => {
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phone_number': phoneNumber,
  };
}
