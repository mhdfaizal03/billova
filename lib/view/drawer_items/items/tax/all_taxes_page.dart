import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/models/services/tax_service.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/local_Storage/tax_local_store.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/tax/add_tax_page.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';

class AllTaxesPage extends StatefulWidget {
  const AllTaxesPage({super.key});

  @override
  State<AllTaxesPage> createState() => _AllTaxesPageState();
}

class _AllTaxesPageState extends State<AllTaxesPage> with RouteAware {
  // Note: RouteAware needs a RouteObserver setup in main.dart to work fully like Category page.
  // Assuming strict copy-paste from Category which used routeObserver.
  // If routeObserver is global in main.dart, we need to import it.
  // Viewing Category page again, it imports 'package:billova/main.dart' where I assume routeObserver is.

  final TextEditingController _searchCtr = TextEditingController();

  List<Tax> _taxes = [];
  List<Tax> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTaxes();
    _searchCtr.addListener(_applySearch);
  }

  // RouteAware omitted for brevity/safety unless I confirm main.dart exports routeObserver.
  // But to support "refresh on back", usually simpler to use await Navigator.push then refresh.
  // The Category page used that logic too (line 165). RouteAware was extra.
  // I'll stick to simple await for now to avoid compilation errors if routeObserver isn't public.

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  Future<void> _loadTaxes() async {
    // 1. Load from Local Storage first
    try {
      final local = await TaxLocalStore.loadAll();
      if (mounted && local.isNotEmpty) {
        setState(() {
          _taxes = local;
          _filtered = local;
          _loading = false;
        });
      }
    } catch (_) {
      // Ignore local error
    }

    // 2. Fetch from Network
    try {
      if (_taxes.isEmpty) {
        setState(() => _loading = true);
      }

      final list = await TaxService.fetchTaxes();
      if (!mounted) return;

      setState(() {
        _taxes = list;
        _filtered = list;
      });
    } catch (e, stack) {
      print('AllTaxesPage Load Error: $e\n$stack');
      // Only show error if we have no data
      if (mounted && _taxes.isEmpty) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to load taxes: $e',
          color: Colors.red,
        );
      }
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
      _filtered = _taxes
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    });
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  Future<void> _confirmDelete(Tax t) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete tax?'),
            content: Text(t.name),
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

    try {
      await TaxService.deleteTax(t.id);

      setState(() {
        _taxes.removeWhere((e) => e.id == t.id);
        _filtered.removeWhere((e) => e.id == t.id);
      });
    } catch (e) {
      // ❌ No snackbar here
    }
  }

  // ─────────────────────────────────────────────
  // TOGGLE ACTIVE
  // ─────────────────────────────────────────────
  Future<void> _toggleStatus(Tax t) async {
    final updated = t.copyWith(isActive: !t.isActive);

    try {
      await TaxService.updateTax(
        id: updated.id,
        name: updated.name,
        rate: updated.rate,
        isActive: updated.isActive,
      );

      setState(() {
        final index = _taxes.indexWhere((e) => e.id == t.id);
        if (index != -1) {
          _taxes[index] = updated;
          _applySearch();
        }
      });
    } catch (_) {
      // ❌ No snackbar here
    }
  }

  // ─────────────────────────────────────────────
  // ADD / EDIT
  // ─────────────────────────────────────────────
  Future<void> _openAddEdit([Tax? t]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaxPage(tax: t)),
    );

    if (result == 'added' || result == 'updated') {
      _loadTaxes();
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
          'Taxes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _loadTaxes, icon: const Icon(Icons.refresh)),
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
                      hintText: 'Search tax...',
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
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No taxes found',
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
                        final t = _filtered[i];

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
                                      '${t.name} (${t.rate}%)',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    sh10,
                                    Text(
                                      t.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: t.isActive
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
                                  value: t.isActive,
                                  activeColor: primary,
                                  onChanged: (_) => _toggleStatus(t),
                                ),
                              ),

                              /// EDIT
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: primary),
                                onPressed: () => _openAddEdit(t),
                              ),

                              /// DELETE
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(t),
                              ),
                            ],
                          ),
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
