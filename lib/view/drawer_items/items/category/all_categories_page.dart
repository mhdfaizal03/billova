import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/category/add_categories_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final TextEditingController _searchCtr = TextEditingController();

  List<Category> _categories = [];
  List<Category> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchCtr.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final data = await CategoryService.getCategories(pagination: false);
      if (!mounted) return;

      setState(() {
        _categories = data;
        _filtered = data;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = [];
        _filtered = [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────
  void _applySearch() {
    final q = _searchCtr.text.toLowerCase();
    setState(() {
      _filtered = _categories
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    });
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<void> _confirmDelete(Category c) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete category?'),
            content: Text(c.name),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    await CategoryService.deleteCategory(c.id);
    setState(() {
      _categories.removeWhere((e) => e.id == c.id);
      _applySearch();
    });
  }

  // ─────────────────────────────────────────────
  // TOGGLE ACTIVE
  // ─────────────────────────────────────────────
  Future<void> _toggleStatus(Category c) async {
    final old = c.isActive;

    setState(() => c.isActive = !c.isActive);

    try {
      await CategoryService.updateCategory(
        id: c.id,
        name: c.name,
        isActive: c.isActive,
      );
    } catch (_) {
      setState(() => c.isActive = old); // rollback
    }
  }

  // ─────────────────────────────────────────────
  // ADD / EDIT
  // ─────────────────────────────────────────────
  Future<void> _openAddEdit([Category? c]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditCategoryPage(category: c)),
    );

    if (result == 'added' || result == 'updated') {
      _loadCategories();
    }
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final primary = AppColors().browcolor;

    return Scaffold(
      backgroundColor: primary,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        foregroundColor: AppColors().creamcolor,
        child: const Icon(Icons.add_rounded),
        onPressed: () => _openAddEdit(),
      ),
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                  : _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No categories found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 100,
                        // top: 12,
                      ),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => sh10,
                      itemBuilder: (_, i) {
                        final c = _filtered[i];

                        return Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  value: c.isActive,
                                  activeColor: primary,
                                  onChanged: (_) => _toggleStatus(c),
                                ),
                              ),

                              /// EDIT
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: primary),
                                onPressed: () => _openAddEdit(c),
                              ),

                              /// DELETE
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(c),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
