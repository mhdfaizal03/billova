import 'package:billova/models/model/models/order_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/data/services/sales_service.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';

class RecieptsPage extends StatefulWidget {
  const RecieptsPage({super.key});

  @override
  State<RecieptsPage> createState() => _RecieptsPageState();
}

class _RecieptsPageState extends State<RecieptsPage> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  final _searchCtr = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReciepts();
  }

  Future<void> _loadReciepts() async {
    final orders = await SalesService.getOrders();
    orders.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (mounted) {
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
        _loading = false;
      });
    }
  }

  void _filter(String query) {
    setState(() {
      _filteredOrders = _allOrders
          .where((o) => o.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
        title: const Text("Digital Receipts"),
      ),
      body: CurveScreen(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: CustomField(
                    text: "Search Receipt ID",
                    controller: _searchCtr,
                    onChanged: _filter,
                    suffix: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? ShimmerHelper.buildGridShimmer(
                      itemCount: 8,
                      crossAxisCount: ResponsiveHelper.isMobile(context)
                          ? 1
                          : 2,
                      itemHeight: 100,
                    )
                  : _filteredOrders.isEmpty
                  ? const Center(child: Text("No matching receipts found"))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isMobile(context)
                            ? 1
                            : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 100, // 📏 More space for content
                      ),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: primary.withOpacity(0.1),
                              child: Icon(Icons.description, color: primary),
                            ),
                            title: Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'dd-MM-yyyy • HH:mm',
                              ).format(order.dateTime),
                            ),
                            trailing: Text(
                              "₹${order.total}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () => _viewReceipt(order),
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

  void _viewReceipt(OrderModel order) {
    final primary = AppColors().browcolor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Receipt Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Order ID:"),
                        Text(
                          order.id,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Date:"),
                        Text(
                          DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(order.dateTime),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    ...order.items.map(
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${i.quantity} x ${i.productName}${i.variantName != null ? ' (${i.variantName})' : ''}",
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "₹${i.total}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Grand Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "₹${order.total}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
