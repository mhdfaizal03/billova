import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'add_edit_category_page.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  List<Category> _categories = [];
  List<Category> _filtered = [];
  bool _loading = true;

  final TextEditingController _searchCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchCtr.addListener(_applySearch);
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final data = await CategoryService.getCategories(pagination: false);
      if (!mounted) return;
      setState(() {
        _categories = data;
        _filtered = data;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applySearch() {
    final q = _searchCtr.text.toLowerCase();
    setState(() {
      _filtered = _categories
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _deleteCategory(Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(c.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await CategoryService.deleteCategory(c.id);
    _loadCategories();
  }

  Future<void> _toggleStatus(Category c) async {
    await CategoryService.updateCategory(
      id: c.id,
      name: c.name,
      isActive: !c.isActive,
    );
    _loadCategories();
  }

  Future<void> _openAddEdit([Category? c]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditCategoryPage(category: c)),
    );
    if (result == true) _loadCategories();
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
        title: const Text('Categories'),
      ),
      body: CurveScreen(
        child: Column(
          children: [
            /// SEARCH
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtr,
                decoration: InputDecoration(
                  hintText: 'Search category...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// LIST
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadCategories,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => sh10,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];

                          return Dismissible(
                            key: ValueKey(c.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              await _deleteCategory(c);
                              return false;
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.05),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        sh10,
                                        Text(
                                          c.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: c.isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// TOGGLE
                                  Switch(
                                    value: c.isActive,
                                    onChanged: (_) => _toggleStatus(c),
                                  ),

                                  /// EDIT
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _openAddEdit(c),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
