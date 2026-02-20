import 'package:billova/models/services/tax_service.dart';
import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/utils/networks/internet_helper.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'; // For context in snackbar if needed, or prefer passing context

class TaxProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Tax> _taxes = [];

  bool get isLoading => _isLoading;
  List<Tax> get taxes => _taxes;

  // ───────── FETCH ─────────
  Future<void> fetchTaxes({bool? isActive}) async {
    setLoading(true);
    try {
      if (await NetworkHelper.hasInternet()) {
        final netTaxes = await TaxService.fetchTaxes(isActive: isActive);
        _taxes = netTaxes;
      } else {
        if (Get.context != null) {
          CustomSnackBar.showError(Get.context!, 'No internet connection');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching taxes: $e');
    } finally {
      setLoading(false);
    }
  }

  // ───────── CREATE ─────────
  Future<Tax?> createTax({
    required String name,
    required double rate,
    required bool isActive,
  }) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('create');
      return null;
    }

    setLoading(true);
    try {
      final newTax = await TaxService.createTax(
        name: name,
        rate: rate,
        isActive: isActive,
      );
      _taxes.add(newTax);
      notifyListeners();
      return newTax;
    } catch (e) {
      if (kDebugMode) print('Error creating tax: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ───────── UPDATE ─────────
  Future<bool> updateTax({
    required String id,
    required String name,
    required double rate,
    required bool isActive,
  }) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('update');
      return false;
    }

    setLoading(true);
    try {
      await TaxService.updateTax(
        id: id,
        name: name,
        rate: rate,
        isActive: isActive,
      );

      // Update local state manually since service might not return object
      final index = _taxes.indexWhere((t) => t.id == id);
      if (index != -1) {
        _taxes[index] = _taxes[index].copyWith(
          name: name,
          rate: rate,
          isActive: isActive,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error updating tax: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ───────── DELETE ─────────
  Future<bool> deleteTax(String id) async {
    if (!await NetworkHelper.hasInternet()) {
      _showOfflineMessage('delete');
      return false;
    }

    setLoading(true);
    try {
      await TaxService.deleteTax(id);
      _taxes.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error deleting tax: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showOfflineMessage(String action) {
    if (Get.context != null) {
      CustomSnackBar.showError(
        Get.context!,
        'Cannot $action tax while offline',
      );
    }
  }
}
