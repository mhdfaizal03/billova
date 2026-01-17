import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/models/services/tax_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/exceptions/network_exception.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditTaxPage extends StatefulWidget {
  final Tax? tax;
  const AddEditTaxPage({super.key, this.tax});

  @override
  State<AddEditTaxPage> createState() => _AddEditTaxPageState();
}

class _AddEditTaxPageState extends State<AddEditTaxPage> {
  late final TextEditingController _nameCtr;
  late final TextEditingController _rateCtr;
  final _formKey = GlobalKey<FormState>();

  bool _isActive = true;
  bool _loading = false;

  bool get _isEdit => widget.tax != null;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.tax?.name ?? '');
    _rateCtr = TextEditingController(text: widget.tax?.rate.toString() ?? '');
    _isActive = widget.tax?.isActive ?? true;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name = _nameCtr.text.trim();
    final rate = double.tryParse(_rateCtr.text.trim()) ?? 0;

    try {
      if (_isEdit) {
        await TaxService.updateTax(
          id: widget.tax!.id,
          name: name,
          rate: rate,
          isActive: _isActive,
        );

        Get.back(result: 'updated');
        return;
      }

      await TaxService.createTax(name: name, rate: rate, isActive: _isActive);

      Get.back(result: 'added');
    } on NetworkException catch (e) {
      CustomSnackBar.show(
        context: context,
        color: Colors.red,
        message: e.message,
      );
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        color: Colors.red,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        title: Text(
          _isEdit ? 'Edit Tax' : 'Add Tax',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: CurveScreen(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtr,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Tax name',
                    hintText: 'Eg: VAT',
                    filled: true,
                    fillColor: Colors.white.withOpacity(.95),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tax name is required';
                    }
                    return null;
                  },
                ),

                sh20,

                TextFormField(
                  controller: _rateCtr,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Tax Rate (%)',
                    hintText: 'Eg: 5',
                    filled: true,
                    fillColor: Colors.white.withOpacity(.95),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tax rate is required';
                    }
                    if (double.tryParse(v) == null) {
                      return 'Invalid rate';
                    }
                    return null;
                  },
                ),

                sh20,

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.95),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tax status',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: _isActive,
                          activeColor: primary,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: _isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: primary))
                      : CustomButtons(
                          onPressed: _loading ? null : _submit,
                          text: Text(_isEdit ? 'Update Tax' : 'Save Tax'),
                        ),
                ),

                sh20,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _rateCtr.dispose();
    super.dispose();
  }
}
