import 'package:billova/main.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/model/models/ticket_item_model.dart';
import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:billova/controllers/category_provider.dart';
import 'package:billova/controllers/product_provider.dart';
import 'package:billova/controllers/tax_provider.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_home_drawer.dart';
import 'package:billova/view/ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final GlobalKey _totalKey = GlobalKey();
  final TextEditingController _searchCtr = TextEditingController();

  // Mock data for the dropdown
  List<Category> _categories = [];
  List<Tax> _taxes = [];
  String _selectedCategory = 'All';

  List<TicketItem> ticketItems = [];

  double get total => ticketItems.fold(0.0, (sum, item) => sum + item.total);
  int get selectedItemCount => ticketItems.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchCtr.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();
      final taxProvider = context.read<TaxProvider>();

      await categoryProvider.fetchCategories();
      await productProvider.fetchProducts();
      await taxProvider.fetchTaxes();

      if (!mounted) return;

      setState(() {
        _categories = categoryProvider.categories;
        _taxes = taxProvider.taxes;

        if (_selectedCategory != 'All' &&
            !_categories.any((c) => c.id == _selectedCategory)) {
          _selectedCategory = 'All';
        }

        _applyFilter();
      });
    } catch (e, stacktrace) {
      print("Error loading data: $e\n$stacktrace");
      if (mounted) {
        CustomSnackBar.showError(context, "Failed to load data");
      }
    }
  }

  void _applyFilter() {
    setState(
      () {},
    ); // Preserved to trigger UI rebuild when search filters change
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final Color primaryColor = colors.browcolor;

    return Scaffold(
      drawerEdgeDragWidth: 100,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: primaryColor,
      drawer: buildGlassDrawer(context),
      appBar: AppBar(
        surfaceTintColor: primaryColor,
        shadowColor: primaryColor,
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Billova',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            sw10,
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_outlined),
          ),
        ],
      ),
      floatingActionButton: total <= 0
          ? SizedBox()
          : GestureDetector(
              onTap: () async {
                final result = await Get.to<List<TicketItem>>(
                  () => TicketPage(items: ticketItems),
                  transition: Transition.cupertino,
                );

                if (result != null) {
                  setState(() {
                    ticketItems = result;
                  });
                }
              },

              child:
                  Card(
                        elevation: 6,
                        margin: EdgeInsets.zero,
                        child: Container(
                          key: _totalKey,
                          width: ResponsiveHelper.isMobile(context)
                              ? mq.width / 2.5
                              : ResponsiveHelper.isTablet(context)
                              ? 300
                              : 400,
                          height: 80,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors().creamcolor,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'TOTAL',
                                          style: TextStyle(
                                            fontSize: 14,
                                            letterSpacing: 1.1,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors().browcolor,
                                          ),
                                        ),

                                        Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: AppColors().browcolor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              selectedItemCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${total.toStringAsFixed(2)}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors().browcolor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(
                        begin: 1,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
            ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CurveScreen(
          child: Column(
            children: [
              // --- Search and Filter Bar ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    controller: _searchCtr,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 12),
                      hintText: 'Search product...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      suffixIcon: _searchCtr.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtr.clear();
                                setState(() {}); // trigger rebuild
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      _applyFilter();
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

              // --- Categories Horizontal List ---
              Consumer<CategoryProvider>(
                builder: (context, catProvider, _) {
                  if (catProvider.isLoading && catProvider.categories.isEmpty) {
                    return ShimmerHelper.buildCategoryPillShimmer();
                  }

                  final categories = catProvider.categories;
                  return Container(
                    height: 30,
                    margin: const EdgeInsets.only(bottom: 0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final cat = isAll ? null : categories[index - 1];
                        final id = isAll ? 'All' : cat!.id;
                        final name = isAll ? 'All' : cat!.name;
                        final isSelected = _selectedCategory == id;

                        return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = id;
                                    _applyFilter();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                            .slideX(begin: -0.2);
                      },
                    ),
                  );
                },
              ),

              // --- Grid View for Items/Tickets ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: SingleChildScrollView(
                    child: Consumer<ProductProvider>(
                      builder: (context, prodProvider, _) {
                        // Dynamic Filtering
                        final query = _searchCtr.text.trim().toLowerCase();
                        List<Product> displayProducts =
                            (_selectedCategory == 'All')
                            ? prodProvider.products
                            : prodProvider.products
                                  .where(
                                    (p) => p.categoryId == _selectedCategory,
                                  )
                                  .toList();

                        if (query.isNotEmpty) {
                          displayProducts = displayProducts
                              .where(
                                (p) => p.name.toLowerCase().contains(query),
                              )
                              .toList();
                        }

                        return Column(
                          children: [
                            sh10,
                            if (prodProvider.isLoading &&
                                prodProvider.products.isEmpty)
                              ShimmerHelper.buildProductGridShimmer(
                                context: context,
                              )
                            else if (displayProducts.isEmpty)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: mq.height * 0.6,
                                ),
                                child: const Center(
                                  child: Text("No products found"),
                                ),
                              )
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              ResponsiveHelper.isMobile(context)
                                              ? 3
                                              : ResponsiveHelper.isTablet(
                                                  context,
                                                )
                                              ? 5
                                              : 8,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 0.75,
                                        ),
                                    itemCount: displayProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = displayProducts[index];
                                      return Builder(
                                        builder: (itemContext) {
                                          return InkWell(
                                            onTap: () {
                                              final box =
                                                  itemContext.findRenderObject()
                                                      as RenderBox?;
                                              if (box == null) return;

                                              final startOffset = box
                                                  .localToGlobal(
                                                    box.size.center(
                                                      Offset.zero,
                                                    ),
                                                  );

                                              if (product.variants != null &&
                                                  product
                                                      .variants!
                                                      .options
                                                      .isNotEmpty) {
                                                _showVariantSelection(
                                                  context,
                                                  product,
                                                  startOffset,
                                                );
                                              } else {
                                                // Find Tax
                                                final tax = _taxes
                                                    .firstWhereOrNull(
                                                      (t) =>
                                                          t.id == product.taxId,
                                                    );

                                                _addToTicket(
                                                  product.name,
                                                  {
                                                    'name': null,
                                                    'price': product.salePrice,
                                                  },
                                                  taxId: product.taxId,
                                                  taxRate: tax?.rate ?? 0.0,
                                                  isTaxIncluded:
                                                      product.isTaxIncluded,
                                                );

                                                _flyToCart(
                                                  startOffset,
                                                  product.imageUrl ?? '',
                                                );
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  .90,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    spreadRadius: 1.5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.15),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  // --- Image Section ---
                                                  Expanded(
                                                    flex: 6,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child:
                                                            product.imageUrl ==
                                                                null
                                                            ? Container(
                                                                width: double
                                                                    .infinity,
                                                                color: primaryColor
                                                                    .withOpacity(
                                                                      0.05,
                                                                    ),
                                                                child: Icon(
                                                                  Icons
                                                                      .fastfood_outlined,
                                                                  color: primaryColor
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  size: 30,
                                                                ),
                                                              )
                                                            : CachedNetworkImage(
                                                                imageUrl: product
                                                                    .imageUrl!,
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder: (_, __) => ShimmerHelper.rectangular(
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  shapeBorder: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                ),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      err,
                                                                    ) => Container(
                                                                      color: primaryColor
                                                                          .withOpacity(
                                                                            0.05,
                                                                          ),
                                                                      child: const Icon(
                                                                        Icons
                                                                            .error_outline,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),

                                                  // --- Info Section ---
                                                  Expanded(
                                                    flex: 4,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            6,
                                                            0,
                                                            6,
                                                            8,
                                                          ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            product.name,
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: primaryColor
                                                                  .withOpacity(
                                                                    0.9,
                                                                  ),
                                                            ),
                                                          ),
                                                          Text(
                                                            '₹${product.salePrice}',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.2, duration: 400.ms);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            total <= 0
                                ? const SizedBox(height: 30)
                                : const SizedBox(height: 120),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVariantSelection(
    BuildContext context,
    Product product,
    Offset startOffset,
  ) {
    const primary = Color(0xFF6B4226);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Drag Handle ---
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primary.withOpacity(0.9),
                          ),
                        ),
                        const Text(
                          'Select your preferred size/variant',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: primary.withOpacity(0.5),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: primary.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- Variants Grid ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
                itemCount: product.variants!.options.length,
                itemBuilder: (context, index) {
                  final option = product.variants!.options[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      final tax = _taxes.firstWhereOrNull(
                        (t) => t.id == product.taxId,
                      );

                      _addToTicket(
                        product.name,
                        {'name': option.optionName, 'price': option.optionRate},
                        taxId: product.taxId,
                        taxRate: tax?.rate ?? 0.0,
                        isTaxIncluded: product.isTaxIncluded,
                      );
                      _flyToCart(startOffset, product.imageUrl ?? '');
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primary.withOpacity(0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            option.optionName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: primary.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${option.optionRate}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  void _addToTicket(
    String product,
    Map<String, dynamic>? variant, {
    String? taxId,
    double taxRate = 0.0,
    bool isTaxIncluded = false,
  }) {
    final String? variantName = variant?['name'];
    // Price from product/variant is usually the "Sale Price" entered by user.
    // We need to determine if this includes tax or not.
    double rawPrice = (variant?['price'] as num?)?.toDouble() ?? 0.0;

    // Calculate Base Price for TicketItem
    double basePrice;
    if (isTaxIncluded) {
      // Inclusive: Sale Price = Base + (Base * Rate/100) = Base * (1 + Rate/100)
      // Base = Sale Price / (1 + Rate/100)
      basePrice = rawPrice / (1 + (taxRate / 100));
    } else {
      // Exclusive: Sale Price IS Base Price
      basePrice = rawPrice;
    }

    final index = ticketItems.indexWhere(
      (e) => e.productName == product && e.variantName == variantName,
    );

    setState(() {
      if (index != -1) {
        ticketItems[index].quantity++;
      } else {
        ticketItems.add(
          TicketItem(
            productName: product,
            variantName: variantName, // null for non-variant
            price: basePrice,
            quantity: 1,
            taxId: taxId,
            taxRate: taxRate,
          ),
        );
      }
    });
  }

  void _flyToCart(Offset start, String imageUrl) {
    // 🔐 SAFETY CHECK
    if (_totalKey.currentContext == null) return;

    final overlay = Overlay.of(context);

    final renderObject = _totalKey.currentContext!.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;

    final box = renderObject;
    final end = box.localToGlobal(box.size.center(Offset.zero));

    final entry = OverlayEntry(
      builder: (_) => _FlyImage(start: start, end: end, imageUrl: imageUrl),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 700), () {
      entry.remove();
    });
  }
}

//---------------fly image---------------

class _FlyImage extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String imageUrl;

  const _FlyImage({
    required this.start,
    required this.end,
    required this.imageUrl,
  });

  @override
  State<_FlyImage> createState() => _FlyImageState();
}

class _FlyImageState extends State<_FlyImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;
  late final Animation<Offset> a;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    a = Tween(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    c.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: a,
      builder: (_, __) => Positioned(
        left: a.value.dx,
        top: a.value.dy,
        child: Transform.scale(
          scale: 1 - c.value * .4,
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            // child: Image.network(widget.imageUrl, width: 40, height: 40),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }
}
