import 'dart:ui';
import 'package:billova/controllers/category_provider.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;

  const AddEditCategoryDialog({super.key, this.category});

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _isActive = widget.category!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<CategoryProvider>();
    bool success;

    if (widget.category != null) {
      success = await provider.updateCategory(
        widget.category!.id,
        _nameController.text.trim(),
        isActive: _isActive,
      );
    } else {
      success = await provider.createCategory(
        _nameController.text.trim(),
        isActive: _isActive,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      CustomSnackBar.show(
        context: context,
        message: widget.category != null
            ? 'Category updated'
            : 'Category created',
        color: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.only(top: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
        title: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              widget.category != null ? 'Edit Category' : 'New Category',
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomField(
                  controller: _nameController,
                  text: 'Category Name',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name required' : null,
                ),
                sh10,
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  activeColor: AppColors().browcolor,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors().browcolor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
