import 'package:billova/main.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/models/model/models/ticket_item_model.dart';
import 'package:billova/models/services/category_services.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_home_drawer.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/view/ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _totalKey = GlobalKey();
  bool _isSearchOpen = false;
  final TextEditingController _searchCtr = TextEditingController();

  Offset position = const Offset(20, 500);

  List<Map<String, dynamic>> items = [
    {
      'title': 'Shawarma',
      'imageUrl':
          'https://imgs.search.brave.com/rLdwGjnmP5aHPAuNh9B_wzUhO9zTveboFoXvoUyO9Ys/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNDEv/OTI2LzMxMy9zbWFs/bC9haS1nZW5lcmF0/ZWQtYS1jbG9zZS11/cC1vZi1hLWRlbGlj/aW91cy1zdGVhbXkt/Y2hpY2tlbi1zaGF3/YXJtYS13cmFwLXdp/dGgtZnJlc2gtdmVn/ZXRhYmxlcy1hbmQt/c3BpY2VzLWZyZWUt/cGhvdG8uanBlZw',
      'price': 120, // fallback price
      'variants': [
        {'name': 'Chicken Shawarma', 'price': 120},
        {'name': 'Beef Shawarma', 'price': 150},
        {'name': 'Jumbo Shawarma', 'price': 180},
      ],
    },

    {
      'title': 'Shawaya',
      'imageUrl':
          'https://imgs.search.brave.com/hCtQyCpQE_Sewd4aSTSTNz5sGXuBfdgoZ7Hqrh8TvNU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMuZGVsaXZlcnlo/ZXJvLmlvL2ltYWdl/L3RhbGFiYXQvTWVu/dUl0ZW1zL2Z1bGxf/c2hhd2F5YV80MF8l/RDglQjQlRDklODgl/RDglQTclRDklOEFf/NjM3NDU0NjY1NjA4/NTE5OTgwLmpwZw',
      'price': 180,
    },

    {
      'title': 'Burger',
      'imageUrl':
          'https://imgs.search.brave.com/1ZwtOBbyuJmBZgyGBBTe6avE_q7DqaK2p7GgH-TBxfo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS1waG90by9k/ZWxpY2lvdXMtYnVy/Z2VyLXN0dWRpb18y/My0yMTUxODQ2NDkz/LmpwZz9zZW10PWFp/c19oeWJyaWQmdz03/NDAmcT04MA',
      'price': 140,
    },

    {
      'title': 'Pizza',
      'imageUrl':
          'https://imgs.search.brave.com/JgnCwQoVisLzsoo4hY79-vdGjZxjgzokIg8LrkoHqOc/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjMv/NDY1LzUwMy9zbWFs/bC9sZXZpdGF0aW9u/LXBpenphLW9uLWJs/YWNrLWJhY2tncm91/bmQtYWktZ2VuZXJh/dGVkLXBob3RvLmpw/Zw',
      'price': 250,
    },

    {
      'title': 'Fried Chicken',
      'imageUrl':
          'https://imgs.search.brave.com/b8_-SDTQNU5TmYF1Ve3Dn8NqCt-OoDxHIyCzTqxIWbY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNDgv/NDA5LzMwOC9zbWFs/bC9kZWxpY2lvdXMt/ZnJpZWQtY2hpY2tl/bi1vbi10cmFuc3Bh/cmVudC1iYWNrZ3Jv/dW5kLWZyZWUtcG5n/LnBuZw',
      'price': 200,
    },

    {
      'title': 'Sandwich',
      'imageUrl':
          'https://imgs.search.brave.com/UIha--XPvpC6pYgsV6SMGvhHI55jg2SjdX1XKvb2EXM/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNTYv/ODU3LzI3NC9zbWFs/bC9kZWxpY2lvdXMt/Z3JpbGxlZC1jaGlj/a2VuLXNhbmR3aWNo/LXdpdGgtZnJlc2gt/Z3JlZW5zLWFuZC1z/YXZvcnktc2F1Y2Ut/c2VydmVkLW9uLXdv/b2Rlbi1ib2FyZC1w/aG90by5qcGVn',
      'price': 120,
    },

    {
      'title': 'Momos',
      'imageUrl':
          'https://imgs.search.brave.com/Yt4pCcc0u_nhyR0GmKKCHdXOYLJVM1GkzVryflEFYSE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzL2I5L2Ix/L2UxL2I5YjFlMWM1/YTdjYTM1MDg1ODcx/OWQwY2FlZDYxMTg3/LmpwZw',
      'price': 100,
    },

    {
      'title': 'Pasta',
      'imageUrl':
          'https://imgs.search.brave.com/FxHivqH1fUDT-qBiBn7sU_PcD7DiZ_McVDU_hYoReGw/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/Zm9vZGFuZHdpbmUu/Y29tL3RobWIvOEpr/M1pnZzZTVzhwQnJv/cGR5aWxSankzUXpF/PS8xNTAweDAvZmls/dGVyczpub191cHNj/YWxlKCk6bWF4X2J5/dGVzKDE1MDAwMCk6/c3RyaXBfaWNjKCkv/Q2hpY2tlbi1QaWNj/YXRhLVBhc3RhLUZU/LU1BRy1SRUNJUEUt/MDIyNS04MDgxMGU2/ODUwODc0MmE2YTNk/ZWM4YmFhN2RjYTQ5/Ni5qcGc',
      'price': 180,
    },

    {
      'title': 'Noodles',
      'imageUrl':
          'https://imgs.search.brave.com/F8zWM5POWaSTTuwzbLl8Iho5qb1xNqv5pFyBYIOw0CU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cy4x/MjNyZi5jb20vNDUw/d20vcGV0ZWVycy9w/ZXRlZXJzMTcwMS9w/ZXRlZXJzMTcwMTAw/MDQ5LzY4NzM3NjQ2/LWNoaW5lc2Utbm9v/ZGxlcy1jaGlja2Vu/LWhvdC1wZXBwZXJz/LWFuZC1nYXJsaWMt/aW4uanBnP3Zlcj02',
      'price': 160,
    },

    {
      'title': 'Ice Cream',
      'imageUrl':
          'https://imgs.search.brave.com/8Nl07LjojV1dioaSigFAjm8zJnFr1Uw5FwzYfba-23M/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTM1/MTcwNTU5L3Bob3Rv/L2ljZWNyZWFtLXRo/cmVlLWJhbGxzLWlu/LXdhZmVyLndlYnA_/YT0xJmI9MSZzPTYx/Mng2MTImdz0wJms9/MjAmYz11MUhaaENI/WTFWM24tNlg5bG04/RTRoaDFQQVpXSWR4/MkVfcHZ2ZGZ5M204/PQ',
      'price': 90,
    },

    {
      'title': 'Coffee',
      'imageUrl':
          'https://imgs.search.brave.com/v8p3h9dfnYO3w0YUFJ0irJTQxbO0X_TkU-CTDLfw5FY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTM2/NjcxMjM4NC9waG90/by9ibGFjay1jb2Zm/ZWUtaW4tYS13aGl0/ZS1tdWctd2l0aC1j/aW5uYW1vbi1zdGlj/a3Mtb24tYS1zYXVj/ZXItb24tYS1ncmV5/LXRhYmxlLWNvcHkt/c3BhY2UuanBnP3M9/NjEyeDYxMiZ3PTAm/az0yMCZjPWNzWjRm/SmZFdXE3aUFxbHZs/YzQwSGFyTV9rSElP/WDRIUGNnRmZlbUpR/eWM9',
      'price': 70,
    },

    {
      'title': 'Juice',
      'imageUrl':
          'https://imgs.search.brave.com/BEji7Wl-IvIlYx459nMgQqvUd1ETeQkI2s4dOL_9Hj4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjYv/NTQ5LzI5MS9zbWFs/bC9vcmFuZ2UtZnJl/c2gtanVpY2UtaW4t/YS1ib3R0bGUtaXNv/bGF0ZWQtb24tb3Jh/bmdlLWJhY2tncm91/bmQtcGhvdG8uanBn',
      'price': 80,
    },

    {
      'title': 'Cake',
      'imageUrl':
          'https://imgs.search.brave.com/XrkZLpSCSE9f2JzmxVzUkA3SZLJmYle_c39Z219H8GI/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS1wc2Qv/Y2FrZS1wb3VyZWQt/d2l0aC1jaG9jb2xh/dGUtZGVjb3JhdGVk/LXdpdGgtZGlmZmVy/ZW50LWNvb2tpZXMt/dHJhbnNwYXJlbnQt/YmFja2dyb3VuZF84/NDQ0My02MjcyLmpw/Zz9zZW10PWFpc19o/eWJyaWQmdz03NDAm/cT04MA',
      'price': 150,
    },

    {
      'title': 'Donut',
      'imageUrl':
          'https://imgs.search.brave.com/oAvY_Zhd32Gq3k6H4oz1vpax-DYOiwKBdSkuMMLDm5E/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAyLzQzLzUzLzU1/LzM2MF9GXzI0MzUz/NTUwM19NUHhYNlN3/SExGUzVIMFhkSlBD/OGhXT2JUOXVRbmJ0/MC5qcGc',
      'price': 60,
    },

    {
      'title': 'Mandhi',
      'imageUrl':
          'https://imgs.search.brave.com/jvYMM6Z32xie_1nRq45jwSnosUL_Aon1XZB85-qZNg8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS1waG90/by9jaGlja2VuLWJp/cml5YW5pLWtlcmFs/YS1zdHlsZS1jaGlj/a2VuLWRodW0tYmly/aXlhbmktbWFkZS11/c2luZy1qZWVyYS1y/aWNlLXNwaWNlcy1h/cnJhbmdlZF8xMTI3/NjMtMTA0MC5qcGc_/c2VtdD1haXNfaHli/cmlkJnc9NzQw',
      'price': 220, // default
      'variants': [
        {'name': 'Normal Mandhi', 'price': 220},
        {'name': 'Alfahm Mandhi', 'price': 260},
        {'name': 'Peri Peri Mandhi', 'price': 280},
      ],
    },
  ];

  List<TicketItem> ticketItems = [];

  int get total => ticketItems.fold(0, (sum, item) => sum + item.total);

  // Mock data for the dropdown
  List<Category> _categories = [];
  String _selectedCategory = 'All';
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await CategoryService.fetchActiveCategories();

      if (!mounted) return;

      setState(() {
        _categories = data;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCategories = false);
    }
  }

  int get selectedItemCount => ticketItems.length;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final Color primaryColor = colors.browcolor;
    final Color secondaryColor = colors.creamcolor;

    return Scaffold(
      drawerEdgeDragWidth: 100,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: primaryColor,
      drawer: buildGlassDrawer(context),
      appBar: AppBar(
        surfaceTintColor: primaryColor,
        shadowColor: primaryColor,
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Billova',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            sw10,
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_add)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: total <= 0
          ? SizedBox()
          : GestureDetector(
              onTap: () async {
                final result = await Get.to<List<TicketItem>>(
                  () => TicketPage(items: ticketItems),
                  transition: Transition.cupertino,
                );

                if (result != null) {
                  setState(() {
                    ticketItems = result;
                  });
                }
              },

              child: Card(
                elevation: 6,
                margin: EdgeInsets.zero,
                child: Container(
                  key: _totalKey,
                  width: mq.width / 3,
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors().creamcolor,
                  ),
                  child: Row(
                    children: [
                      // const SizedBox(width: 18),
                      // CircleAvatar(
                      //   radius: 28,
                      //   backgroundColor: AppColors().browcolor.withOpacity(
                      //     0.12,
                      //   ),
                      //   child: Icon(
                      //     Icons.receipt_long_rounded,
                      //     color: AppColors().browcolor,
                      //     size: 30,
                      //   ),
                      // ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL',
                                  style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1.1,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors().browcolor,
                                  ),
                                ),

                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: AppColors().browcolor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      selectedItemCount.toString(),
                                      style: const TextStyle(
                                        color: Colors
                                            .white, // ⚠️ white for visibility
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹$total',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors().browcolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                    ],
                  ),
                ),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: CurveScreen(
          child: Column(
            children: [
              // --- Search and Filter Bar ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.browcolor.withOpacity(.3),
                      width: 0.5,
                    ),
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 0.2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: child,
                        );
                      },
                      child: _isSearchOpen
                          // SEARCH MODE
                          ? Row(
                              key: const ValueKey('search_mode'),
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtr,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                        top: 12,
                                      ),
                                      hintText: 'Search ticket...',
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: primaryColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close),
                                        color: primaryColor,
                                        onPressed: () {
                                          setState(() {
                                            _searchCtr.clear();
                                            _isSearchOpen = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          // FILTER + SEARCH ICON MODE
                          : Row(
                              key: const ValueKey('filter_mode'),
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      icon: Icon(
                                        Icons.filter_list,
                                        color: primaryColor,
                                      ),
                                      hint: const Text('Filter'),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 15,
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'All',
                                          child: Text('All Categories'),
                                        ),
                                        ..._categories.map(
                                          (c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        ),
                                      ],
                                      onChanged: (String? newValue) {
                                        if (newValue == null) return;
                                        setState(() {
                                          _selectedCategory = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        _isSearchOpen = true;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.search,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              // --- Grid View for Items/Tickets ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        sh10,
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: constraints.maxWidth < 600
                                        ? 3
                                        : 6,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.9,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Builder(
                                  builder: (itemContext) {
                                    return InkWell(
                                      onTap: () {
                                        final box =
                                            itemContext.findRenderObject()
                                                as RenderBox?;
                                        if (box == null) return;

                                        final startOffset = box.localToGlobal(
                                          box.size.center(Offset.zero),
                                        );

                                        if (item.containsKey('variants') &&
                                            item['variants'] != null) {
                                          _showVariants(item, startOffset);
                                        } else {
                                          _addToTicket(
                                            item['title'],
                                            item.containsKey('price')
                                                ? {
                                                    'name': null,
                                                    'price': item['price'],
                                                  }
                                                : null,
                                          );

                                          _flyToCart(
                                            startOffset,
                                            item['imageUrl'],
                                          );
                                        }
                                      },
                                      // borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(.90),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1.5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: primaryColor.withOpacity(
                                              0.15,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: 1.5,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Image.network(
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              // width: 90,
                                                              // height: 80,
                                                              color: primaryColor
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color: primaryColor
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  size: 40,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                      items[index]['imageUrl'],
                                                      // width: 90,
                                                      // height: 80,
                                                      fit: BoxFit.cover,
                                                      // color: primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Text(
                                              items[index]['title'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),

                                            /// PRICE
                                            Text(
                                              '₹${items[index]['price']}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        total <= 0
                            ? SizedBox(height: 30)
                            : SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVariants(Map<String, dynamic> item, Offset tapPosition) {
    final List variants = item['variants'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Title
            Text(
              item['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// Variant Grid
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: variants.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: constraints.maxWidth > 600
                        ? mq.width * 0.20
                        : mq.width * 0.3,
                    childAspectRatio: 0.80,
                  ),
                  itemBuilder: (context, index) {
                    final v = variants[index];
                    final String name = v['name'] ?? '';
                    final int price = (v['price'] as num?)?.toInt() ?? 0;

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                        _addToTicket(item['title'], {
                          'name': name,
                          'price': price,
                        });
                        _flyToCart(tapPosition, item['imageUrl']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// IMAGE (fallback if not provided)
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                child: AspectRatio(
                                  aspectRatio: 1.8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        child: Image.network(
                                          v['imageUrl'] ?? item['imageUrl'],
                                          width: 85,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// NAME
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            /// PRICE
                            Text(
                              '₹$price',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addToTicket(String product, Map<String, dynamic>? variant) {
    final String? variantName = variant?['name'];
    final int price = (variant?['price'] as num?)?.toInt() ?? 0;

    final index = ticketItems.indexWhere(
      (e) => e.productName == product && e.variantName == variantName,
    );

    setState(() {
      if (index != -1) {
        ticketItems[index].quantity++;
      } else {
        ticketItems.add(
          TicketItem(
            productName: product,
            variantName: variantName, // null for non-variant
            price: price,
            quantity: 1,
          ),
        );
      }
    });
  }

  void _flyToCart(Offset start, String imageUrl) {
    // 🔐 SAFETY CHECK
    if (_totalKey.currentContext == null) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final renderObject = _totalKey.currentContext!.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;

    final box = renderObject;
    final end = box.localToGlobal(box.size.center(Offset.zero));

    final entry = OverlayEntry(
      builder: (_) => _FlyImage(start: start, end: end, imageUrl: imageUrl),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 700), () {
      entry.remove();
    });
  }
}

//---------------fly image---------------

class _FlyImage extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String imageUrl;

  const _FlyImage({
    required this.start,
    required this.end,
    required this.imageUrl,
  });

  @override
  State<_FlyImage> createState() => _FlyImageState();
}

class _FlyImageState extends State<_FlyImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;
  late final Animation<Offset> a;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    a = Tween(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    c.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: a,
      builder: (_, __) => Positioned(
        left: a.value.dx,
        top: a.value.dy,
        child: Transform.scale(
          scale: 1 - c.value * .4,
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            // child: Image.network(widget.imageUrl, width: 40, height: 40),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }
}

// class DraggableFAB extends StatefulWidget {
//   final VoidCallback onPressed;

//   const DraggableFAB({super.key, required this.onPressed});

//   @override
//   State<DraggableFAB> createState() => _DraggableFABState();
// }

// class _DraggableFABState extends State<DraggableFAB> {
//   // Initial position (you can tweak this)
//   Offset position = Offset(mq.width * .46, mq.height * .75);

//   // Size of your card (roughly)
//   final double cardWidth = mq.width / 2;
//   final double cardHeight = 130;

//   // Call this from AppBar to reset
//   void resetPosition() {
//     setState(() {
//       position = Offset(mq.width * .46, mq.height * .75);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Positioned(
//       left: position.dx,
//       top: position.dy,
//       child: GestureDetector(
//         // This makes it "drag anywhere"
//         onPanUpdate: (details) {
//           setState(() {
//             double newX = position.dx + details.delta.dx;
//             double newY = position.dy + details.delta.dy;

//             // clamp inside screen
//             newX = newX.clamp(0.0, size.width - cardWidth);
//             newY = newY.clamp(0.0, size.height - cardHeight);

//             position = Offset(newX, newY);
//           });
//         },
//         onTap: widget.onPressed, // optional: still clickable
//         child: _fab(),
//       ),
//     );
//   }

//   Widget _fab() {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Card(
//         elevation: 6,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Container(
//           width: mq.width / 2,
//           height: 130,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(24),
//             gradient: LinearGradient(
//               colors: [
//                 AppColors().browcolor.withOpacity(0.95),
//                 AppColors().browcolor.withOpacity(0.8),
//               ],
//             ),
//           ),
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white.withOpacity(0.90),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 18),
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: AppColors().browcolor.withOpacity(0.12),
//                   child: Icon(
//                     Icons.receipt_long_rounded,
//                     color: AppColors().browcolor,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(width: 18),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'TOTAL',
//                         style: TextStyle(
//                           fontSize: 14,
//                           letterSpacing: 1.1,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors().browcolor,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         '300/-',
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w900,
//                           color: AppColors().browcolor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 18),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
