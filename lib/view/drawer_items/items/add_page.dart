import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // ▶ dropdown data
  final List<String> _filters = ['All Items', 'Pending', 'Completed', 'Drafts'];

  String _selectedFilter = 'All Items';

  // ▶ search toggle
  bool _isSearchMode = false;
  final TextEditingController _searchCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColor = AppColors().browcolor;

    return Scaffold(
      backgroundColor: AppColors().browcolor,
      appBar: AppBar(
        backgroundColor: appColor,
        leading: CustomAppBarBack(),
        foregroundColor: Colors.white,
        titleSpacing: 0,

        // ▼ TITLE AREA SWITCHES BASED ON SEARCH MODE
        title: _isSearchMode
            ? TextField(
                controller: _searchCtr,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // TODO: Filter your items
                },
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  dropdownColor: appColor,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _filters
                      .map(
                        (e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _selectedFilter = val;
                    });
                  },
                ),
              ),

        // ▼ ACTION ICON CHANGES BETWEEN SEARCH & CLOSE
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearchMode) {
                  // exiting search → clear search field
                  _searchCtr.clear();
                }
                _isSearchMode = !_isSearchMode;
              });
            },
          ),
        ],
      ),

      body: CurveScreen(child: Column(children: [])),
    );
  }
}
