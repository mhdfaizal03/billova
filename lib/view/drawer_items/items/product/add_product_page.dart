import 'package:billova/controllers/category_provider.dart';
import 'package:billova/controllers/product_provider.dart';
import 'package:billova/controllers/tax_provider.dart';
import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';
import 'package:provider/provider.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;
  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _remakesController = TextEditingController();
  final _mrpController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _stockController = TextEditingController();

  // Variant Add Controllers
  final _varNameController = TextEditingController();
  final _varRateController = TextEditingController();

  // State
  List<VariantOption> _variants = [];
  File? _imageFile;
  String? _selectedCategoryId;
  String? _selectedTaxId;

  // Track if user manually changed selection
  bool _isImageDeleted = false;
  bool _isTaxIncluded = false;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
    _salePriceController.addListener(() => setState(() {}));

    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _remakesController.text = widget.product!.remakes;
      _mrpController.text = widget.product!.mrp?.toString() ?? '';
      _salePriceController.text = widget.product!.salePrice?.toString() ?? '';
      _purchasePriceController.text =
          widget.product!.purchasePrice?.toString() ?? '';
      _stockController.text = widget.product!.stockQuantity?.toString() ?? '';

      _selectedCategoryId = widget.product!.categoryId;
      _selectedTaxId = widget.product!.taxId;
      _isTaxIncluded = widget.product!.isTaxIncluded;

      if (widget.product!.variants != null) {
        _variants = List.from(widget.product!.variants!.options);
      }
    }
  }

  Future<void> _loadDependencies() async {
    // Fetch data via Providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<TaxProvider>().fetchTaxes();
    });
  }

  void _addVariant() {
    final name = _varNameController.text.trim();
    final rate = double.tryParse(_varRateController.text.trim());

    if (name.isEmpty || rate == null) {
      CustomSnackBar.show(
        context: context,
        message: 'Enter valid variant name and rate',
        color: Colors.red,
      );
      return;
    }

    setState(() {
      _variants.add(VariantOption(optionName: name, optionRate: rate));
      _varNameController.clear();
      _varRateController.clear();
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageDeleted = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _isImageDeleted = true;
    });
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              try {
                final success = await context
                    .read<CategoryProvider>()
                    .createCategory(name, isActive: true);

                if (success && mounted) {
                  // Try to find the new category to select it
                  try {
                    final cats = context.read<CategoryProvider>().categories;
                    final newCat = cats.firstWhere((c) => c.name == name);
                    setState(() {
                      _selectedCategoryId = newCat.id;
                    });
                  } catch (_) {}

                  CustomSnackBar.show(
                    context: context,
                    message: 'Category added',
                    color: Colors.green,
                  );
                }
              } catch (e) {
                CustomSnackBar.show(
                  context: context,
                  message: 'Failed to add category: $e',
                  color: Colors.red,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTaxDialog() async {
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tax'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tax Name'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Rate (%)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final rate = double.tryParse(rateController.text.trim());
              if (name.isEmpty || rate == null) return;
              Navigator.pop(ctx);

              try {
                final newTax = await context.read<TaxProvider>().createTax(
                  name: name,
                  rate: rate,
                  isActive: true,
                );

                if (newTax != null && mounted) {
                  setState(() {
                    _selectedTaxId = newTax.id;
                  });
                  CustomSnackBar.show(
                    context: context,
                    message: 'Tax added',
                    color: Colors.green,
                  );
                }
              } catch (e) {
                CustomSnackBar.show(
                  context: context,
                  message: 'Failed to add tax: $e',
                  color: Colors.red,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();

    try {
      final newProduct = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        remakes: _remakesController.text.trim(),
        mrp: double.tryParse(_mrpController.text),
        salePrice: double.tryParse(_salePriceController.text),
        purchasePrice: double.tryParse(_purchasePriceController.text),
        stockQuantity: int.tryParse(_stockController.text),
        categoryId: _selectedCategoryId ?? "",
        taxId: _selectedTaxId ?? "",
        isTaxIncluded: _isTaxIncluded,
        variants: _variants.isNotEmpty
            ? ProductVariants(options: _variants)
            : null,
        imageUrl: _isImageDeleted ? "" : widget.product?.imageUrl,
      );

      bool success = false;
      if (widget.product == null) {
        final result = await provider.createProduct(
          newProduct,
          imageFile: _imageFile,
        );
        success = result != null;
      } else {
        success = await provider.updateProduct(
          newProduct,
          imageFile: _imageFile,
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.toString(),
          color: Colors.red,
        );
      }
    }
  }

  InputDecoration _inputDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(.95),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors().browcolor;
    final catProvider = context.watch<CategoryProvider>();
    final taxProvider = context.watch<TaxProvider>();
    final prodProvider = context.watch<ProductProvider>();

    // Prepare lists
    final categories = catProvider.categories;
    final taxes = taxProvider.taxes;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body:
          (catProvider.isLoading || taxProvider.isLoading) &&
              (categories.isEmpty && taxes.isEmpty)
          ? ShimmerHelper.buildFormShimmer(context)
          : CurveScreen(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:
                                  [
                                        Center(
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: _pickImage,
                                                child: Container(
                                                  height: 120,
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    image: _imageFile != null
                                                        ? DecorationImage(
                                                            image: FileImage(
                                                              _imageFile!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : (!_isImageDeleted &&
                                                              widget
                                                                      .product
                                                                      ?.imageUrl !=
                                                                  null)
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                              widget
                                                                  .product!
                                                                  .imageUrl!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child:
                                                      (_imageFile == null &&
                                                          (_isImageDeleted ||
                                                              widget
                                                                      .product
                                                                      ?.imageUrl ==
                                                                  null))
                                                      ? Icon(
                                                          Icons
                                                              .add_a_photo_outlined,
                                                          size: 40,
                                                          color:
                                                              Colors.grey[400],
                                                        )
                                                      : null,
                                                ),
                                              ),
                                              if (_imageFile != null ||
                                                  (!_isImageDeleted &&
                                                      widget
                                                              .product
                                                              ?.imageUrl !=
                                                          null))
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: _removeImage,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.8),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _nameController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: _inputDeco(
                                            'Product Name',
                                          ),
                                          validator: (v) =>
                                              v!.isEmpty ? 'Required' : null,
                                        ),
                                        sh10,
                                        TextFormField(
                                          controller: _remakesController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: _inputDeco(
                                            'Description / Remakes',
                                          ),
                                          maxLines: 2,
                                        ),
                                        sh10,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _salePriceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: _inputDeco(
                                                  'Sale Price',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _mrpController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: _inputDeco('MRP'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        sh10,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _purchasePriceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: _inputDeco(
                                                  'Purchase Price',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _stockController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: _inputDeco(
                                                  'Stock Qty',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        sh20,
                                        const Text(
                                          "Category",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              .95,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _verifyId(
                                                _selectedCategoryId,
                                                categories,
                                              ),
                                              isExpanded: true,
                                              hint: const Text(
                                                "Select Category",
                                              ),
                                              items: [
                                                const DropdownMenuItem(
                                                  value: "",
                                                  child: Text("None"),
                                                ),
                                                ...categories.map((c) {
                                                  return DropdownMenuItem(
                                                    value: c.id,
                                                    child: Text(c.name),
                                                  );
                                                }),
                                                const DropdownMenuItem(
                                                  value: "new",
                                                  child: Text(
                                                    "New Category",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (val) {
                                                if (val == "new") {
                                                  _showAddCategoryDialog();
                                                } else {
                                                  setState(() {
                                                    _selectedCategoryId = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        sh20,
                                        const Text(
                                          "Tax",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              .95,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _verifyId(
                                                _selectedTaxId,
                                                taxes,
                                              ),
                                              isExpanded: true,
                                              hint: const Text("Select Tax"),
                                              items: [
                                                const DropdownMenuItem(
                                                  value: "",
                                                  child: Text("None"),
                                                ),
                                                ...taxes.map((t) {
                                                  return DropdownMenuItem(
                                                    value: t.id,
                                                    child: Text(
                                                      '${t.name} - ${t.rate}%',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                                const DropdownMenuItem(
                                                  value: "new",
                                                  child: Text(
                                                    "New Tax",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (val) {
                                                if (val == "new") {
                                                  _showAddTaxDialog();
                                                } else {
                                                  setState(() {
                                                    _selectedTaxId = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        sh10,
                                        CheckboxListTile(
                                          value: _isTaxIncluded,
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(
                                                () => _isTaxIncluded = val,
                                              );
                                            }
                                          },
                                          title: const Text(
                                            "Tax Inclusive",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          activeColor: primary,
                                          contentPadding: EdgeInsets.zero,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                        if (_selectedTaxId != null &&
                                            _selectedTaxId!.isNotEmpty)
                                          _buildTaxCalculationSummary(taxes),
                                        sh20,
                                        const Text(
                                          "Variants",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        // Variants List
                                        if (_variants.isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: _variants
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                    int idx = entry.key;
                                                    VariantOption v =
                                                        entry.value;
                                                    return ListTile(
                                                      dense: true,
                                                      title: Text(v.optionName),
                                                      subtitle: Text(
                                                        'Rate: ${v.optionRate}',
                                                      ),
                                                      trailing: IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () =>
                                                            _removeVariant(idx),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                            ),
                                          ),

                                        // Add Variant Form
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.95,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.08,
                                                ),
                                                spreadRadius: 1,
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.08,
                                                                ),
                                                            spreadRadius: 1,
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            _varNameController,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        decoration: _inputDeco(
                                                          'Variant Size',
                                                          hint: 'e.g. Small',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.08,
                                                                ),
                                                            spreadRadius: 1,
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            _varRateController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: _inputDeco(
                                                          'Rate',
                                                          hint: '0.0',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 40,
                                                child: ElevatedButton.icon(
                                                  onPressed: _addVariant,
                                                  icon: const Icon(Icons.add),
                                                  label: const Text(
                                                    'Add Variant',
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors()
                                                                .browcolor,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        sh30,
                                        SizedBox(
                                          height: 46,
                                          width: double.infinity,
                                          child: prodProvider.isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: primary,
                                                      ),
                                                )
                                              : CustomButtons(
                                                  onPressed:
                                                      prodProvider.isLoading
                                                      ? null
                                                      : _submit,
                                                  text: Text(
                                                    widget.product == null
                                                        ? 'Create Product'
                                                        : 'Update Product',
                                                  ),
                                                ),
                                        ),
                                        sh20,
                                      ]
                                      .animate(interval: 50.ms)
                                      .fadeIn(duration: 400.ms)
                                      .slideY(
                                        begin: 0.1,
                                        curve: Curves.easeOutQuad,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Ensure selected ID exists in the list to avoid Dropdown errors
  String? _verifyId(String? id, List<dynamic> items) {
    if (id == null || id.isEmpty) return null;
    if (items.any((item) => item.id == id)) return id;
    // If not found (maybe deleted or strictly not in list), return null or empty if allowed
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remakesController.dispose();
    _mrpController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _varNameController.dispose();
    _varRateController.dispose();
    super.dispose();
  }

  Widget _buildTaxCalculationSummary(List<Tax> taxes) {
    // 1. Get Rate
    double rate = 0;
    try {
      final tax = taxes.firstWhere((t) => t.id == _selectedTaxId);
      rate = tax.rate;
    } catch (_) {}

    if (rate == 0) return const SizedBox.shrink();

    // 2. Get Input Price
    double inputPrice = double.tryParse(_salePriceController.text) ?? 0;

    // 3. Calculate
    double basePrice = 0;
    double taxAmount = 0;
    double total = 0;

    if (_isTaxIncluded) {
      // Inclusive: Input is TOTAL
      total = inputPrice;
      basePrice = total / (1 + (rate / 100));
      taxAmount = total - basePrice;
    } else {
      // Exclusive: Input is BASE
      basePrice = inputPrice;
      taxAmount = basePrice * (rate / 100);
      total = basePrice + taxAmount;
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tax Breakdown (${_isTaxIncluded ? 'Inclusive' : 'Exclusive'})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem("Base Price", basePrice),
              _summaryItem("Tax ($rate%)", taxAmount),
              _summaryItem("Total Payable", total, isTotal: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }
}
