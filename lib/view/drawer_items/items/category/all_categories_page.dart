import 'package:billova/main.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';

import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/category/add_categories_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';
import 'package:provider/provider.dart';
import 'package:billova/controllers/category_provider.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> with RouteAware {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _loadCategories(); // reload when coming back
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchCtr.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  Future<void> _loadCategories() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    if (provider.categories.isEmpty) {
      await provider.fetchCategories();
    }
    if (mounted) {
      setState(() {
        _categories = provider.categories;
        _filtered = List.from(_categories);
      });
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
            title: const Text('Delete category?'),
            content: Text(c.name),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.deleteCategory(c.id);

    if (success && mounted) {
      setState(() {
        _categories.removeWhere((e) => e.id == c.id);
        _filtered.removeWhere((e) => e.id == c.id);
      });
    }
  }

  // ─────────────────────────────────────────────
  // TOGGLE ACTIVE
  // ─────────────────────────────────────────────
  Future<void> _toggleStatus(Category c) async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.updateCategory(
      c.id,
      c.name,
      isActive: !c.isActive,
    );

    if (success && mounted) {
      setState(() {
        final index = _categories.indexWhere((e) => e.id == c.id);
        if (index != -1) {
          _categories[index] = _categories[index].copyWith(
            isActive: !c.isActive,
          );
          _applySearch();
        }
      });
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
      _loadCategories(); // 🔥 reload from API
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
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
              ),
            ),

            /// LIST
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && _filtered.isEmpty) {
                    return ShimmerHelper.buildGridShimmer(
                      itemCount: 9,
                      crossAxisCount: ResponsiveHelper.isMobile(context)
                          ? 1
                          : ResponsiveHelper.isTablet(context)
                          ? 2
                          : 3,
                      itemHeight: 80,
                    );
                  }

                  if (_filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 100,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context)
                          ? 1
                          : ResponsiveHelper.isTablet(context)
                          ? 2
                          : 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 80,
                    ),
                    itemCount: _filtered.length,
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
