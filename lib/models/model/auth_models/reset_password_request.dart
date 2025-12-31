class ResetPasswordRequest {
  final String? email;
  final String? phoneNumber;

  ResetPasswordRequest({this.email, this.phoneNumber});

  Map<String, dynamic> toJson() => {
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phone_number': phoneNumber,
  };
}
