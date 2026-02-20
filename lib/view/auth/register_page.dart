import 'dart:async';

import 'package:billova/controllers/auth_provider.dart';
import 'package:billova/models/model/auth_models/signup_request.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/view/auth/confirm_otp_page.dart';
import 'package:billova/view/privacy/terms_and_conditions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ---------------- COUNTRIES ----------------

const List<String> countryList = [
  'India',
  'United States',
  'United Kingdom',
  'Canada',
  'Australia',
  'Germany',
  'France',
  'Japan',
  'China',
  'Brazil',
  'Italy',
  'Spain',
  'Russia',
  'Mexico',
  'South Africa',
  'Saudi Arabia',
  'United Arab Emirates',
  'Singapore',
  'Malaysia',
  'Sri Lanka',
  'Nepal',
  'Bangladesh',
  'Pakistan',
  'New Zealand',
];

const Map<String, String> countryFlagMap = {
  'India': '🇮🇳',
  'United States': '🇺🇸',
  'United Kingdom': '🇬🇧',
  'Canada': '🇨🇦',
  'Australia': '🇦🇺',
  'Germany': '🇩🇪',
  'France': '🇫🇷',
  'Japan': '🇯🇵',
  'China': '🇨🇳',
  'Brazil': '🇧🇷',
  'Italy': '🇮🇹',
  'Spain': '🇪🇸',
  'Russia': '🇷🇺',
  'Mexico': '🇲🇽',
  'South Africa': '🇿🇦',
  'Saudi Arabia': '🇸🇦',
  'United Arab Emirates': '🇦🇪',
  'Singapore': '🇸🇬',
  'Malaysia': '🇲🇾',
  'Sri Lanka': '🇱🇰',
  'Nepal': '🇳🇵',
  'Bangladesh': '🇧🇩',
  'Pakistan': '🇵🇰',
  'New Zealand': '🇳🇿',
};

const Map<String, String> countryCodeMap = {
  'India': '+91',
  'United States': '+1',
  'United Kingdom': '+44',
  'Canada': '+1',
  'Australia': '+61',
  'Germany': '+49',
  'France': '+33',
  'Japan': '+81',
  'China': '+86',
  'Brazil': '+55',
  'Italy': '+39',
  'Spain': '+34',
  'Russia': '+7',
  'Mexico': '+52',
  'South Africa': '+27',
  'Saudi Arabia': '+966',
  'United Arab Emirates': '+971',
  'Singapore': '+65',
  'Malaysia': '+60',
  'Sri Lanka': '+94',
  'Nepal': '+977',
  'Bangladesh': '+880',
  'Pakistan': '+92',
  'New Zealand': '+64',
};

/// ---------------- VALIDATORS ----------------

class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone required';
    if (!RegExp(r'^[0-9+]{7,15}$').hasMatch(v)) {
      return 'Invalid phone';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password required';
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    ).hasMatch(v)) {
      return 'Weak password';
    }
    return null;
  }

  static String? confirm(String? v, String p) {
    if (v == null || v.isEmpty) return 'Confirm password';
    if (v != p) return 'Passwords do not match';
    return null;
  }
}

/// ---------------- REGISTER PAGE ----------------

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmCtr = TextEditingController();
  final companyNameCtr = TextEditingController();
  final dealerCodeCtr = TextEditingController();

  int otpTimer = 0;
  Timer? _otpTimer;

  bool pass = true;
  bool confirmpass = true;
  bool isAgree = false;

  String? _selectedCountry = 'India';

  bool isSigningUp = false;

  /// ---------------- REGISTER ----------------
  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() ||
        _selectedCountry == null ||
        !isAgree) {
      if (!isAgree) {
        CustomSnackBar.show(
          color: AppColors().browcolor,
          context: context,
          message: 'Please agree to Terms & Conditions',
        );
      }
      return;
    }

    setState(() => isSigningUp = true);

    try {
      final response = await context.read<AuthProvider>().signUp(
        SignupRequest(
          dealerCode: dealerCodeCtr.text.trim(),
          email: emailCtr.text.trim(),
          password: passwordCtr.text.trim(),
          confirmPassword: confirmCtr.text.trim(),
          companyName: companyNameCtr.text.trim(),
          phoneNumber: phoneCtr.text.trim(),
          country: _selectedCountry!.trim(),
        ),
      );

      if (!mounted) return;

      /// ✅ BACKEND CONFIRMS OTP SENT
      if (response.success ||
          response.message.toLowerCase().contains('verification code')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmOtpPage(phoneNumber: phoneCtr.text.trim()),
          ),
        );
      } else {
        CustomSnackBar.show(
          color: AppColors().browcolor,
          context: context,
          message: response.message,
        );
      }
    } finally {
      if (mounted) setState(() => isSigningUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    IconData icon = pass ? Icons.visibility : Icons.visibility_off;
    IconData confirmIcon = confirmpass
        ? Icons.visibility
        : Icons.visibility_off;
    final flag = _selectedCountry != null
        ? countryFlagMap[_selectedCountry!]
        : '🌍';

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: ConstrainBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Hero(
                                tag: 'logo',
                                child: Image.asset(
                                  'assets/images/billova_logo.png',
                                  fit: BoxFit.cover,
                                  height: mq.height * 0.15,
                                ),
                              ),
                              Flex(
                                direction: Axis.vertical,
                                children: [
                                  CustomField(
                                    text: 'Email',
                                    controller: emailCtr,
                                    validator: Validators.email,
                                  ),
                                  sh10,

                                  /// COUNTRY PICKER
                                  GestureDetector(
                                    onTap: () async {
                                      final res = await _showCountryBottomSheet(
                                        context,
                                      );
                                      if (res != null) {
                                        setState(() {
                                          _selectedCountry = res;
                                          // phoneCtr.text = countryCodeMap[res] ?? '';
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            flag.toString(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedCountry ??
                                                  'Select country',
                                              style: TextStyle(
                                                color: _selectedCountry == null
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down),
                                        ],
                                      ),
                                    ),
                                  ),

                                  sh10,

                                  /// PHONE
                                  CustomField(
                                    text: 'Phone Number',
                                    controller: phoneCtr,
                                    validator: Validators.phone,
                                    keyboardType: TextInputType.phone,
                                  ),

                                  sh10,

                                  CustomField(
                                    text: 'Company Name',
                                    controller: companyNameCtr,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Company Name required';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                  ),

                                  sh10,

                                  CustomField(
                                    text: 'Dealer Code (Optional)',
                                    controller: dealerCodeCtr,
                                    keyboardType: TextInputType.text,
                                  ),

                                  sh10,
                                  CustomField(
                                    text: 'Password',
                                    controller: passwordCtr,
                                    obscure: pass,
                                    validator: Validators.password,
                                    suffix: GestureDetector(
                                      onTap: () => setState(() => pass = !pass),
                                      child: Icon(icon),
                                    ),
                                  ),
                                  sh10,

                                  CustomField(
                                    text: 'Confirm Password',
                                    controller: confirmCtr,
                                    obscure: confirmpass,
                                    suffix: GestureDetector(
                                      onTap: () => setState(
                                        () => confirmpass = !confirmpass,
                                      ),
                                      child: Icon(confirmIcon),
                                    ),
                                    validator: (v) =>
                                        Validators.confirm(v, passwordCtr.text),
                                  ),
                                ],
                              ),

                              Flex(
                                direction: Axis.vertical,
                                children: [
                                  CheckboxListTile(
                                    checkboxScaleFactor: 1.4,
                                    checkboxShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    contentPadding: EdgeInsets.all(2),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    activeColor: AppColors().browcolor,
                                    value: isAgree,
                                    onChanged: (v) =>
                                        setState(() => isAgree = v ?? false),
                                    title: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        children: [
                                          const TextSpan(
                                            text:
                                                'By continuing, you acknowledge that you have read and agree to our ',
                                          ),
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(
                                              color: AppColors().browcolor,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const TermsAndConditionsPage(),
                                                  ),
                                                );
                                              },
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: AppColors().browcolor,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const PrivacyPolicyPage(),
                                                  ),
                                                );
                                              },
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),

                                  sh20,
                                  Hero(
                                    tag: 'regbtn',
                                    child: CustomButtons(
                                      text: isSigningUp
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: mq.width * .040,
                                              ),
                                            ),
                                      onPressed: isSigningUp
                                          ? null
                                          : () async {
                                              await _register();
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: 10, left: 10, child: CustomBackButton()),
        ],
      ),
    );
  }

  /// ---------------- COUNTRY BOTTOM SHEET ----------------

  Future<String?> _showCountryBottomSheet(BuildContext context) async {
    TextEditingController searchCtr = TextEditingController();
    List<String> filtered = List.from(countryList);

    return showModalBottomSheet<String>(
      context: context,
      // isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            void filter(String q) {
              setModal(() {
                filtered = q.isEmpty
                    ? List.from(countryList)
                    : countryList
                          .where(
                            (c) => c.toLowerCase().contains(q.toLowerCase()),
                          )
                          .toList();
              });
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors().browcolor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const Text(
                    'Select Country',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  CustomField(
                    text: 'Search country',
                    controller: searchCtr,
                    onChanged: filter,
                    suffix: const Icon(Icons.search),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return ListTile(
                          leading: Text(countryFlagMap[c] ?? '🌍'),
                          title: Text(c),
                          onTap: () => Navigator.pop(context, c),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    emailCtr.dispose();
    phoneCtr.dispose();
    passwordCtr.dispose();
    confirmCtr.dispose();
    companyNameCtr.dispose();
    dealerCodeCtr.dispose();
    super.dispose();
  }
}
