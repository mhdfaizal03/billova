import 'dart:io';
import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/models/services/product_service.dart';
import 'package:billova/utils/networks/internet_helper.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  List<Product> get products => _products;

  // ───────── FETCH ─────────
  Future<void> fetchProducts() async {
    setLoading(true);
    try {
      if (await NetworkHelper.hasInternet()) {
        final netProds = await ProductService.fetchProducts();
        _products = netProds;
      } else {
        if (Get.context != null) {
          CustomSnackBar.showError(Get.context!, 'No internet connection');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching products: $e');
    } finally {
      setLoading(false);
    }
  }

  // ───────── CREATE ─────────
  Future<Product?> createProduct(Product product, {File? imageFile}) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('create');
      return null;
    }

    setLoading(true);
    try {
      final newProduct = await ProductService.createProduct(
        product,
        imageFile: imageFile,
      );
      _products.add(newProduct);
      notifyListeners();
      return newProduct;
    } catch (e) {
      if (kDebugMode) print('Error creating product: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ───────── UPDATE ─────────
  Future<bool> updateProduct(Product product, {File? imageFile}) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('update');
      return false;
    }

    setLoading(true);
    try {
      final updatedProduct = await ProductService.updateProduct(
        product,
        imageFile: imageFile,
      );

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error updating product: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ───────── DELETE PRODUCT ─────────
  Future<bool> deleteProduct(String id) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('delete');
      return false;
    }

    setLoading(true);
    try {
      await ProductService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error deleting product: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ───────── DELETE IMAGE ─────────
  Future<bool> deleteProductImage(String productId) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('update');
      return false;
    }

    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return false;

    final current = _products[index];

    // Create a new product instance with empty imageUrl to signal deletion
    final updatedModel = Product(
      id: current.id,
      name: current.name,
      remakes: current.remakes,
      mrp: current.mrp,
      salePrice: current.salePrice,
      purchasePrice: current.purchasePrice,
      stockQuantity: current.stockQuantity,
      categoryId: current.categoryId,
      taxId: current.taxId,
      isTaxIncluded: current.isTaxIncluded,
      variants: current.variants,
      imageUrl: '',
    );

    return updateProduct(updatedModel);
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showOfflineMessage(String action) {
    if (Get.context != null) {
      CustomSnackBar.showError(
        Get.context!,
        'Cannot $action product while offline',
      );
    }
  }
}
