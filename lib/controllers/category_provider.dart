import 'package:billova/data/services/category_service.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/utils/local_Storage/category_local_store.dart';
import 'package:billova/utils/networks/internet_helper.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';

class CategoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Category> _categories = [];

  bool get isLoading => _isLoading;
  List<Category> get categories => _categories;

  Future<void> fetchCategories({bool? isActive}) async {
    setLoading(true);
    try {
      if (await NetworkHelper.hasInternet()) {
        final netCats = await CategoryService.fetchCategories(
          isActive: isActive,
        );
        _categories = netCats;
        await CategoryLocalStore.saveAll(netCats);
      } else {
        _categories = await CategoryLocalStore.loadAll();
        if (kDebugMode) print('Loaded categories from local storage');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching categories: $e');
      // Fallback to local if network fails
      _categories = await CategoryLocalStore.loadAll();
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createCategory(String name, {bool isActive = true}) async {
    if (!await NetworkHelper.hasInternet()) {
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Cannot create category while offline',
      );
      return false;
    }

    setLoading(true);
    try {
      final newCategory = await CategoryService.createCategory(
        name,
        isActive: isActive,
      );
      _categories.add(newCategory);
      await CategoryLocalStore.saveAll(_categories); // Sync local
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error creating category: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateCategory(
    String id,
    String name, {
    bool isActive = true,
  }) async {
    if (!await NetworkHelper.hasInternet()) {
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Cannot update category while offline',
      );
      return false;
    }

    setLoading(true);
    try {
      final updatedCategory = await CategoryService.updateCategory(
        id,
        name,
        isActive: isActive,
      );
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        await CategoryLocalStore.saveAll(_categories); // Sync local
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error updating category: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteCategory(String id) async {
    if (!await NetworkHelper.hasInternet()) {
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Cannot delete category while offline',
      );
      return false;
    }

    setLoading(true);
    try {
      await CategoryService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      await CategoryLocalStore.saveAll(_categories); // Sync local
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error deleting category: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
