import 'package:billova/utils/widgets/custom_dialog_box.dart';
import 'package:get/get.dart';
import 'package:billova/controllers/tax_provider.dart';
import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/tax/add_tax_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';
import 'package:provider/provider.dart';

class AllTaxesPage extends StatefulWidget {
  const AllTaxesPage({super.key});

  @override
  State<AllTaxesPage> createState() => _AllTaxesPageState();
}

class _AllTaxesPageState extends State<AllTaxesPage> {
  final TextEditingController _searchCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaxProvider>().fetchTaxes();
    });
  }

  Future<void> _confirmDelete(Tax t) async {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: 'Delete tax?',
        content: 'Are you sure you want to delete ${t.name}?',
        saveText: 'Delete',
        onSave: () async {
          Navigator.pop(context);
          await context.read<TaxProvider>().deleteTax(t.id);
        },
      ),
    );
  }

  Future<void> _toggleStatus(Tax t) async {
    await context.read<TaxProvider>().updateTax(
      id: t.id,
      name: t.name,
      rate: t.rate,
      isActive: !t.isActive,
    );
  }

  Future<void> _openAddEdit([Tax? t]) async {
    await Get.to(() => AddEditTaxPage(tax: t));
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
          'Taxes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<TaxProvider>().fetchTaxes(),
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
              child: Consumer<TaxProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.taxes.isEmpty) {
                    return ShimmerHelper.buildGridShimmer(
                      itemCount: 9,
                      crossAxisCount: ResponsiveHelper.isMobile(context)
                          ? 1
                          : ResponsiveHelper.isTablet(context)
                          ? 2
                          : 3,
                      itemHeight: 80,
                    );
                  }

                  final query = _searchCtr.text.toLowerCase();
                  final filtered = provider.taxes
                      .where((t) => t.name.toLowerCase().contains(query))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No taxes found',
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
                      final t = filtered[i];

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
