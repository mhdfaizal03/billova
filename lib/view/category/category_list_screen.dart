import 'package:billova/controllers/category_provider.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_dialog_box.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';
import 'package:billova/view/category/add_edit_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  void _showAddEditDialog([Category? category]) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditCategoryDialog(category: category),
    );
  }

  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogBox(
        title: 'Delete Category',
        content: 'Are you sure you want to delete this category?',
        saveText: 'Delete',
        onSave: () async {
          Navigator.pop(ctx);
          await context.read<CategoryProvider>().deleteCategory(id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().browcolor,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        title: Text(
          'Categories',
          style: GoogleFonts.aBeeZee(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors().browcolor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors().browcolor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CurveScreen(
        child: ConstrainBox(
          child: Consumer<CategoryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.categories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: ShimmerHelper.buildCategoryListShimmer(itemCount: 8),
                );
              }

              if (provider.categories.isEmpty) {
                return Center(
                  child: Text(
                    'No categories found',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: provider.categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors().browcolor.withOpacity(0.1),
                        child: Icon(
                          Icons.category_rounded,
                          color: AppColors().browcolor,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: category.isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Colors.blue,
                            ),
                            onPressed: () => _showAddEditDialog(category),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteCategory(category.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
