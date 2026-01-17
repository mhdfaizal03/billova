import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/models/services/product_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/loading_shimmer.dart';
import 'package:billova/view/drawer_items/items/product/add_product_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:get/get.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final TextEditingController _searchCtr = TextEditingController();

  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchCtr.addListener(_applySearch);
  }

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  Future<void> _loadProducts() async {
    setState(() => _loading = true);

    try {
      final list = await ProductService.fetchProducts();
      if (!mounted) return;

      setState(() {
        _products = list;
        _filtered = list;
      });
    } catch (_) {
      Get.snackbar(
        "Error",
        "Failed to load products",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
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
      _filtered = _products
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
    });
  }

  // ─────────────────────────────────────────────
  // ADD / EDIT
  // ─────────────────────────────────────────────
  Future<void> _openAddEdit([Product? p]) async {
    final result = await Get.to(() => AddEditProductPage(product: p));

    if (result == true) {
      // _submit returns true
      _loadProducts();
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
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _loadProducts, icon: const Icon(Icons.refresh)),
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
                      hintText: 'Search product...',
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
              child: _loading
                  ? const ProductListShimmer()
                  : _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : GridView.builder(
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
                        final p = _filtered[i];

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
                              // Image
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: p.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: p.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) =>
                                              const ShimmerHelper(
                                                width: 50,
                                                height: 50,
                                                radius: 0,
                                              ),
                                          errorWidget: (_, __, ___) =>
                                              const Icon(Icons.error, size: 20),
                                        )
                                      : const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 24,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    sh10,
                                    Text(
                                      '₹${p.salePrice}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status Toggle removed as it's not in new Product model
                              /// EDIT (View mostly since update not fully impl in service)
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: primary),
                                onPressed: () {
                                  // For now View/Edit logic same
                                  _openAddEdit(p);
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (30 * i).ms).slideX(begin: 0.1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }
}
