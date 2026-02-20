import 'package:billova/utils/widgets/custom_dialog_box.dart';
import 'package:get/get.dart';
import 'package:billova/controllers/product_provider.dart';
import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/product/add_product_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final TextEditingController _searchCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  Future<void> _confirmDelete(Product p) async {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: 'Delete product?',
        content: 'Are you sure you want to delete ${p.name}?',
        saveText: 'Delete',
        onSave: () async {
          Navigator.pop(context);
          await context.read<ProductProvider>().deleteProduct(p.id ?? '');
        },
      ),
    );
  }

  Future<void> _openAddEdit([Product? p]) async {
    await Get.to(() => AddEditProductPage(product: p));
  }

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
          IconButton(
            onPressed: () => context.read<ProductProvider>().fetchProducts(),
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
                    onChanged: (val) => setState(() {}),
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
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.products.isEmpty) {
                    return ShimmerHelper.buildHorizontalCardGridShimmer(
                      context: context,
                      itemCount: 9,
                    );
                  }

                  final query = _searchCtr.text.toLowerCase();
                  final filtered = provider.products
                      .where((p) => p.name.toLowerCase().contains(query))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found',
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
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];

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
                                child:
                                    (p.imageUrl != null &&
                                        p.imageUrl!.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: p.imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            ShimmerHelper.rectangular(
                                              width: double.infinity,
                                              height: double.infinity,
                                              shapeBorder:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  sh10,
                                  Text(
                                    'Rs ${p.salePrice ?? '-'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// EDIT
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: primary),
                              onPressed: () => _openAddEdit(p),
                            ),

                            /// DELETE
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () => _confirmDelete(p),
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

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }
}
