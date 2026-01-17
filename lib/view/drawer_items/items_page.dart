import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/constrained_box.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/category/all_categories_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:billova/view/drawer_items/items/tax/all_taxes_page.dart';
import 'package:billova/view/drawer_items/items/product/all_products_page.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Map<String, dynamic>> list = [
    {
      "icon": Icons.shopping_bag,
      "title": "Products",
      "page": const AllProductsPage(),
    },
    {
      "icon": Icons.category,
      "title": "Categories",
      "page": const AllCategoriesPage(),
    },
    {
      "icon": Icons.attach_money,
      "title": "Taxes",
      "page": const AllTaxesPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().browcolor,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: AppColors().browcolor,
        foregroundColor: Colors.white,
        title: Text("Items"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: CurveScreen(
        child: ConstrainBox(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      list[index]["page"],
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors().browcolor,
                    ),
                    child: ListTile(
                      leading: Icon(list[index]["icon"], color: Colors.white),
                      title: Text(
                        list[index]["title"],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
