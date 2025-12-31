import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category;
  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  late TextEditingController _nameCtr;
  bool _isActive = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.category?.name ?? '');
    _isActive = widget.category?.isActive ?? true;
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (widget.category == null) {
        await CategoryService.createCategory(
          name: _nameCtr.text.trim(),
          isActive: _isActive,
        );
      } else {
        await CategoryService.updateCategory(
          id: widget.category!.id,
          name: _nameCtr.text.trim(),
          isActive: _isActive,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
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
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: CurveScreen(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameCtr,
                decoration: const InputDecoration(labelText: 'Category name'),
              ),
              SwitchListTile(
                value: _isActive,
                title: const Text('Active'),
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
