import 'package:billova/models/model/models/order_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/local_Storage/sales_local_store.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  List<OrderModel> _orders = [];

  // Metrics
  double _totalSales = 0;
  int _totalOrders = 0;
  double _avgOrderValue = 0;
  double _todaySales = 0;

  // Chart Data: Last 7 days [DayName, Amount]
  List<MapEntry<String, double>> _weeklySales = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final orders = await SalesLocalStore.getOrders();
    // Sort Newest First
    orders.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (!mounted) return;

    double sum = 0;
    double todaySum = 0;
    final now = DateTime.now();

    // Weekly Map: 0=Today, 1=Yesterday...
    final Map<int, double> last7Days = {};
    for (int i = 0; i < 7; i++) {
      last7Days[i] = 0;
    }

    for (var o in orders) {
      sum += o.total;

      // Check Today
      if (_isSameDay(o.dateTime, now)) {
        todaySum += o.total;
      }

      // Check Weekly Bucket
      final diff = now.difference(o.dateTime).inDays;
      if (diff >= 0 && diff < 7) {
        last7Days[diff] = (last7Days[diff] ?? 0) + o.total;
      }
    }

    // Prepare Chart Data (Reverse to show oldest -> newest left-right)
    List<MapEntry<String, double>> chartData = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date); // Mon, Tue
      chartData.add(MapEntry(dayName, last7Days[i] ?? 0));
    }

    setState(() {
      _orders = orders;
      _totalSales = sum;
      _totalOrders = orders.length;
      _avgOrderValue = orders.isEmpty ? 0 : sum / orders.length;
      _todaySales = todaySum;
      _weeklySales = chartData;
      _loading = false;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
        title: const Text('Dashboard Analytics'),
      ),
      body: CurveScreen(
        child: _loading
            ? ShimmerHelper.buildDashboardShimmer(context)
            : RefreshIndicator(
                onRefresh: _loadAnalytics,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SUMMARY CARDS ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Total Sales',
                              '₹${_totalSales.toStringAsFixed(0)}',
                              Colors.green.shade700,
                              Icons.attach_money,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Today Sales',
                              '₹${_todaySales.toStringAsFixed(0)}',
                              Colors.blue.shade700,
                              Icons.today,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Total Orders',
                              _totalOrders.toString(),
                              Colors.orange.shade800,
                              Icons.receipt,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Avg Order Value',
                              '₹${_avgOrderValue.toStringAsFixed(0)}',
                              Colors.purple.shade700,
                              Icons.show_chart,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                      sh30,

                      // --- WEEKLY CHART ---
                      const Text(
                        "Last 7 Days Sales",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _weeklySales.map((entry) {
                            // Normalize height relative to max
                            double max = _weeklySales.fold(
                              0,
                              (p, e) => e.value > p ? e.value : p,
                            );
                            if (max == 0) max = 1;
                            final pct = entry.value / max;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                  message: '₹${entry.value}',
                                  child: Container(
                                    width: 30,
                                    height: 120 * pct + 10, // Min height 10
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ).animate().scaleY(
                              begin: 0,
                              duration: 600.ms,
                              curve: Curves.easeOutQuart,
                              alignment: Alignment.bottomCenter,
                            );
                          }).toList(),
                        ),
                      ),

                      sh30,

                      // --- RECENT ORDERS ---
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_orders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No transactions yet."),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _orders.length > 5 ? 5 : _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return Card(
                              elevation: 0,
                              color: Colors.white.withOpacity(0.8),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.receipt_outlined,
                                    color: primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  "Order #${order.id}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat(
                                    'MMM dd, hh:mm a',
                                  ).format(order.dateTime),
                                ),
                                trailing: Text(
                                  "₹${order.total}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
