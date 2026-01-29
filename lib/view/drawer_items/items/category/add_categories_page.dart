import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/scope.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/exceptions/network_exception.dart';
import 'package:billova/utils/local_Storage/category_local_store.dart';
import 'package:billova/utils/networks/internet_helper.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category;
  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  late final TextEditingController _nameCtr;
  final _formKey = GlobalKey<FormState>();

  bool _isActive = true;
  bool _loading = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.category?.name ?? '');
    _isActive = widget.category?.isActive ?? true;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name = _nameCtr.text.trim();

    // 🔍 DUPLICATE CHECK
    try {
      final local = await CategoryLocalStore.loadAll();
      // Check if any OTHER category has the same name (if editing, ignore self)
      final exists = local.any((c) {
        if (_isEdit && c.id == widget.category!.id) return false;
        return c.name.toLowerCase() == name.toLowerCase();
      });

      if (exists) {
        setState(() => _loading = false);
        if (mounted) {
          CustomSnackBar.showError(context, "Category '$name' already exists");
        }
        return;
      }
    } catch (_) {
      // Ignore local check failure and proceed to server
    }

    try {
      if (_isEdit) {
        await CategoryService.updateCategory(
          id: widget.category!.id,
          name: name,
          isActive: _isActive,
        );

        if (mounted) Navigator.pop(context, 'updated');
        return;
      }

      await CategoryService.createCategory(name: name, isActive: _isActive);

      if (mounted) Navigator.pop(context, 'added');
    } on NetworkException catch (e) {
      if (!mounted) return;
      // 🔔 SHOW ERROR ONLY FOR ADD / UPDATE
      CustomSnackBar.show(
        context: context,
        color: Colors.red,
        message: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        color: Colors.red,
        message: e.toString().replaceAll("Exception: ", ""),
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
          _isEdit ? 'Edit Category' : 'Add Category',
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
                    labelText: 'Category name',
                    hintText: 'Eg: Beverages',
                    filled: true,
                    fillColor: Colors.white.withOpacity(.95),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Category name is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Minimum 3 characters';
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
                          'Category status',
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
                          text: Text(
                            _isEdit ? 'Update Category' : 'Save Category',
                          ),
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
    super.dispose();
  }
}
