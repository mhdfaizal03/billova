class LoginRequest {
  final String password;
  final String? email;
  final String? phoneNumber;
  final String? storeId;

  LoginRequest({
    required this.password,
    this.email,
    this.phoneNumber,
    this.storeId,
  });

  Map<String, dynamic> toJson() => {
    'password': password,
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phone_number': phoneNumber,
    if (storeId != null) 'store_id': storeId,
  };
}
