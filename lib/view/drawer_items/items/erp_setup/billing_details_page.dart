import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/local_Storage/settings_local_store.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BillingDetailsPage extends StatefulWidget {
  const BillingDetailsPage({super.key});

  @override
  State<BillingDetailsPage> createState() => _BillingDetailsPageState();
}

class _BillingDetailsPageState extends State<BillingDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtr = TextEditingController();
  final _addressCtr = TextEditingController();
  final _contactCtr = TextEditingController();
  final _gstCtr = TextEditingController();
  final _headerCtr = TextEditingController();
  final _footerCtr = TextEditingController();
  String _logoPath = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final data = await SettingsLocalStore.loadStoreDetails();
    _nameCtr.text = data['name'] ?? "";
    _addressCtr.text = data['address'] ?? "";
    _contactCtr.text = data['contact'] ?? "";
    _gstCtr.text = data['gst'] ?? "";
    _headerCtr.text = data['header'] ?? "";
    _footerCtr.text = data['footer'] ?? "";
    _logoPath = data['logo'] ?? "";
    setState(() => _loading = false);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _logoPath = image.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await SettingsLocalStore.saveStoreDetails(
      name: _nameCtr.text,
      address: _addressCtr.text,
      contact: _contactCtr.text,
      gst: _gstCtr.text,
      header: _headerCtr.text,
      footer: _footerCtr.text,
      logo: _logoPath,
    );

    setState(() => _loading = false);
    if (mounted)
      CustomSnackBar.showSuccess(context, "Billing details saved successfully");
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors().browcolor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Billing Details"),
      ),
      body: CurveScreen(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Picker
                          GestureDetector(
                            onTap: _pickLogo,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: _logoPath.isEmpty
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          "Add Logo",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        File(_logoPath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Business Info",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          sh20,
                          CustomField(
                            text: "Business Name",
                            controller: _nameCtr,
                          ),
                          sh10,
                          CustomField(
                            text: "Address (Line 1, City)",
                            controller: _addressCtr,
                          ),
                          sh10,
                          CustomField(
                            text: "Contact Number",
                            controller: _contactCtr,
                            keyboardType: TextInputType.phone,
                          ),
                          sh10,
                          CustomField(
                            text: "GST / VAT Number",
                            controller: _gstCtr,
                          ),

                          sh20,
                          const Divider(),
                          sh20,

                          const Text(
                            "Receipt Settings",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          sh20,
                          CustomField(
                            text: "Receipt Header Message",
                            controller: _headerCtr,
                          ),
                          sh10,
                          CustomField(
                            text: "Receipt Footer Message",
                            controller: _footerCtr,
                          ),

                          sh20,
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: CustomButtons(
                              text: const Text("Save Details"),
                              onPressed: _save,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
