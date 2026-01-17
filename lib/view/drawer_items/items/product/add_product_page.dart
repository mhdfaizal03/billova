import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/models/services/product_service.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/models/services/tax_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/utils/local_Storage/category_local_store.dart';
import 'package:billova/utils/local_Storage/tax_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  bool _isLoading = false;

  // Dropdown Data
  List<Category> _categories = [];
  List<Tax> _taxes = [];
  List<VariantOption> _variants = [];
  File? _imageFile;
  String? _selectedCategoryId;
  String? _selectedTaxId;
  bool _isLoadingData = true;

  // Track if user manually changed selection to prevent overwriting with original on refresh
  bool _catChanged = false;
  bool _taxChanged = false;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _remakesController.text = widget.product!.remakes;
      _mrpController.text = widget.product!.mrp.toString();
      _salePriceController.text = widget.product!.salePrice.toString();
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _selectedCategoryId = widget.product!.categoryId;
      _selectedTaxId = widget.product!.taxId;
      if (widget.product!.variants != null) {
        _variants = List.from(widget.product!.variants!.options);
      }
    }
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
      });
    }
  }

  Future<void> _loadDependencies() async {
    // 1. CACHE FIRST (Fast load)
    try {
      final localCats = await CategoryLocalStore.loadAll();
      final localTaxes = await TaxLocalStore.loadAll();
      if (mounted && (localCats.isNotEmpty || localTaxes.isNotEmpty)) {
        _updateLists(localCats, localTaxes);
      }
    } catch (_) {
      // Ignore cache errors, wait for network
    }

    // 2. NETWORK (Fresh load)
    try {
      final cats = await CategoryService.fetchCategories();
      final txs = await TaxService.fetchTaxes();

      if (mounted) {
        _updateLists(cats, txs);
      }
    } catch (e) {
      if (mounted) {
        // If we have data from cache, don't show full error unless cache also failed (empty list)
        if (_categories.isEmpty && _taxes.isEmpty) {
          setState(() => _isLoadingData = false);
          CustomSnackBar.show(
            context: context,
            message: 'Failed to load data: $e',
            color: Colors.red,
          );
        } else {
          // Silent error if we have cache, or show toast
          print('Network refresh failed: $e');
        }
      }
    }
  }

  void _updateLists(List<Category> cats, List<Tax> txs) {
    setState(() {
      _categories = cats;
      _taxes = txs;

      bool isEdit = widget.product != null;

      // ── CATEGORY SELECTION LOGIC ──
      // 1. If not changed by user AND IS EDITING AND original ID is in new list, Use Original.
      if (!_catChanged &&
          isEdit &&
          _categories.any((c) => c.id == widget.product!.categoryId)) {
        _selectedCategoryId = widget.product!.categoryId;
      }
      // 2. Else if current selection is valid, Keep it.
      else if (_selectedCategoryId != null &&
          _categories.any((c) => c.id == _selectedCategoryId)) {
        // Keep current
      }
      // 3. Else Default to First (or null if empty)
      else if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      } else {
        _selectedCategoryId = null;
      }

      // ── TAX SELECTION LOGIC ──
      if (!_taxChanged &&
          isEdit &&
          _taxes.any((t) => t.id == widget.product!.taxId)) {
        _selectedTaxId = widget.product!.taxId;
      } else if (_selectedTaxId != null &&
          _taxes.any((t) => t.id == _selectedTaxId)) {
        // Keep current
      } else if (_taxes.isNotEmpty) {
        _selectedTaxId = _taxes.first.id;
      } else {
        _selectedTaxId = null;
      }

      _isLoadingData = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      CustomSnackBar.show(
        context: context,
        message: 'Please select a category',
        color: Colors.red,
      );
      return;
    }
    if (_selectedTaxId == null) {
      CustomSnackBar.show(
        context: context,
        message: 'Please select a tax',
        color: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newProduct = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        remakes: _remakesController.text.trim(),
        mrp: double.tryParse(_mrpController.text) ?? 0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        stockQuantity: int.tryParse(_stockController.text) ?? 0,
        categoryId: _selectedCategoryId!,
        taxId: _selectedTaxId!,
        variants: _variants.isNotEmpty
            ? ProductVariants(options: _variants)
            : null,
      );

      if (widget.product == null) {
        await ProductService.createProduct(newProduct, imageFile: _imageFile);
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Product added successfully',
            color: Colors.green,
          );
          Get.back(result: true);
        }
      } else {
        await ProductService.updateProduct(newProduct, imageFile: _imageFile);
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Product updated successfully',
            color: Colors.green,
          );
          Get.back(result: true);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.toString(),
          color: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator(color: Colors.white))
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
                                          child: GestureDetector(
                                            onTap: _pickImage,
                                            child: Container(
                                              height: 120,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                image: _imageFile != null
                                                    ? DecorationImage(
                                                        image: FileImage(
                                                          _imageFile!,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : (widget
                                                                  .product
                                                                  ?.imageUrl !=
                                                              null
                                                          ? DecorationImage(
                                                              image: NetworkImage(
                                                                widget
                                                                    .product!
                                                                    .imageUrl!,
                                                              ),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null),
                                              ),
                                              child:
                                                  _imageFile == null &&
                                                      widget
                                                              .product
                                                              ?.imageUrl ==
                                                          null
                                                  ? Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      size: 40,
                                                      color: Colors.grey[400],
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
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
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _mrpController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: _inputDeco('MRP'),
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
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
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
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
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
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
                                              value: _selectedCategoryId,
                                              isExpanded: true,
                                              hint: const Text(
                                                "Select Category",
                                              ),
                                              items: _categories.map((c) {
                                                return DropdownMenuItem(
                                                  value: c.id,
                                                  child: Text(c.name),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedCategoryId = val;
                                                  _catChanged = true;
                                                });
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
                                              value: _selectedTaxId,
                                              isExpanded: true,
                                              hint: const Text("Select Tax"),
                                              items: _taxes.map((t) {
                                                return DropdownMenuItem(
                                                  value: t.id,
                                                  child: Text(
                                                    '${t.name} (${t.rate}%)',
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedTaxId = val;
                                                  _taxChanged = true;
                                                });
                                              },
                                            ),
                                          ),
                                        ),

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
                                          child: _isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: primary,
                                                      ),
                                                )
                                              : CustomButtons(
                                                  onPressed: _isLoading
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
}
