import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/view/drawer_items/items/category/all_categories_page.dart';
import 'package:flutter/material.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isActive = true;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await CategoryService.createCategory(
        name: _nameCtr.text.trim(),
        isActive: _isActive,
      );

      if (!mounted) return;

      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: 'Category added successfully',
      );

      Navigator.pop(context, true); // 🔥 important for refresh
    } catch (e) {
      CustomSnackBar.show(
        color: AppColors().browcolor,
        context: context,
        message: '${e.toString().replaceAll('Exception:', '').trim()}',
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
        elevation: 0,
        title: const Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: CurveScreen(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                sh20,

                /// CATEGORY NAME
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

                /// ACTIVE TOGGLE
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
                      Switch(
                        value: _isActive,
                        activeColor: primary,
                        onChanged: (v) {
                          setState(() => _isActive = v);
                        },
                      ),
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

                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 40,
                    width: 160,
                    child: CustomButtons(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllCategoriesPage(),
                          ),
                        );
                      },
                      text: Text('All Categories'),
                    ),
                  ),
                ),

                const Spacer(),

                /// SAVE BUTTON
                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors().browcolor,
                            // strokeWidth: 2,
                          ),
                        )
                      : CustomButtons(
                          onPressed: _loading ? null : _submit,
                          text: const Text('Save Category'),
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
