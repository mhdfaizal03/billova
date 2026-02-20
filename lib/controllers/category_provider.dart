import 'package:billova/models/services/category_services.dart';
import 'package:billova/models/model/category_models/category_model.dart';
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
      } else {
        if (Get.context != null) {
          CustomSnackBar.showError(Get.context!, 'No internet connection');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching categories: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createCategory(String name, {bool isActive = true}) async {
    if (!await NetworkHelper.hasInternet()) {
      if (Get.context != null) {
        CustomSnackBar.show(
          context: Get.context!,
          message: 'Cannot create category while offline',
        );
      }
      return false;
    }

    setLoading(true);
    try {
      final newCategory = await CategoryService.createCategory(
        name: name,
        isActive: isActive,
      );
      _categories.add(newCategory);
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
      if (Get.context != null) {
        CustomSnackBar.show(
          context: Get.context!,
          message: 'Cannot update category while offline',
        );
      }
      return false;
    }

    setLoading(true);
    try {
      await CategoryService.updateCategory(
        id: id,
        name: name,
        isActive: isActive,
      );
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(
          name: name,
          isActive: isActive,
        );
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
      if (Get.context != null) {
        CustomSnackBar.show(
          context: Get.context!,
          message: 'Cannot delete category while offline',
        );
      }
      return false;
    }

    setLoading(true);
    try {
      await CategoryService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
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
