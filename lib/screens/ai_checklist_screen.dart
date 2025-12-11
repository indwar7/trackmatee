import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiChecklistScreen extends StatefulWidget {
  const AiChecklistScreen({super.key});

  @override
  State<AiChecklistScreen> createState() => _AiChecklistScreenState();
}

class _AiChecklistScreenState extends State<AiChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Default categories
  final Map<String, List<String>> _defaultItems = {
    'Essentials': ['Hair Dryer', 'Serum', 'Power Bank', 'Sunglasses', 'Charger'],
    'Travel Items': ['Passport', 'Extra Clothes', 'Travel Pillow', 'Toiletries'],
    'Weather': ['Jacket', 'Umbrella', 'Sunscreen'],
    'Health': ['Painkiller', 'Antacid', 'Band Aid'],
    'Kids & Family': ['Kid Snacks', 'Baby Diapers']
  };

  /// All items (default + user added)
  Map<String, List<String>> _tabItems = {};

  Set<String> _checked = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load checked items
    final saved = prefs.getStringList('checked') ?? [];

    // Load custom items for each tab
    final Map<String, List<String>> customItems = {};
    for (var tabKey in _defaultItems.keys) {
      final custom = prefs.getStringList('custom_$tabKey') ?? [];
      customItems[tabKey] = custom;
    }

    // Merge default + custom items
    final merged = <String, List<String>>{};
    _defaultItems.forEach((tab, defaultList) {
      merged[tab] = [...defaultList, ...customItems[tab]!];
    });

    setState(() {
      _checked = saved.toSet();
      _tabItems = merged;
      _loaded = true;
    });
  }

  Future<void> _saveChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('checked', _checked.toList());
  }

  Future<void> _saveCustomItems(String tabKey) async {
    final prefs = await SharedPreferences.getInstance();
    final defaultCount = _defaultItems[tabKey]!.length;
    final allItems = _tabItems[tabKey]!;
    final customItems = allItems.sublist(defaultCount);
    await prefs.setStringList('custom_$tabKey', customItems);
  }

  void _toggleCheck(String key) {
    setState(() {
      if (_checked.contains(key)) {
        _checked.remove(key);
      } else {
        _checked.add(key);
      }
    });
    _saveChecked();
  }

  double _progressPercent() {
    final total = _tabItems.values.fold<int>(0, (sum, list) => sum + list.length);
    if (total == 0) return 0.0;
    return _checked.length / total;
  }

  void _showAddItemDialog() {
    final activeIndex = _tabController.index;
    final tabName = _tabItems.keys.elementAt(activeIndex);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add item to $tabName',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter item name',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF24222C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final itemName = controller.text.trim();
              if (itemName.isNotEmpty) {
                _addCustomItem(tabName, itemName);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBFA3FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCustomItem(String tabName, String itemName) {
    setState(() {
      _tabItems[tabName]!.add(itemName);
    });
    _saveCustomItems(tabName);
    _showSnack('Added "$itemName" to $tabName');
  }

  void _deleteItem(String tabKey, String item) {
    // Check if it's a custom item (not in default list)
    if (!_defaultItems[tabKey]!.contains(item)) {
      setState(() {
        _tabItems[tabKey]!.remove(item);
        _checked.remove('$tabKey|$item');
      });
      _saveCustomItems(tabKey);
      _saveChecked();
      _showSnack('Deleted "$item"');
    } else {
      _showSnack('Cannot delete default items');
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  Widget _smallProgressSegments(double percent) {
    const int segments = 5;
    final int filled = (percent * segments).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(segments, (i) {
        final bool isFilled = i < filled;
        return Container(
          width: 40,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isFilled ? const Color(0xFFBFA3FF) : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressPercent();
    final percentText = (progress * 100).round().toString();
    final textStyleSmall = TextStyle(color: Colors.white70, fontSize: 12);
    final primaryPurple = const Color(0xFFBFA3FF);

    return Scaffold(
      backgroundColor: const Color(0xFF100F14),
      body: SafeArea(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// TOP SECTION - Progress percentage
              Text(
                '$percentText% packed',
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              Text('Select more items to complete packing',
                  style: textStyleSmall),

              const SizedBox(height: 12),

              /// Progress bar with proper alignment
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('0%', style: textStyleSmall),
                  const SizedBox(width: 12),
                  _smallProgressSegments(progress),
                  const SizedBox(width: 12),
                  Text('100%', style: textStyleSmall),
                ],
              ),

              const SizedBox(height: 24),

              Icon(Icons.backpack_outlined, color: primaryPurple, size: 46),
              const SizedBox(height: 10),
              const Text(
                'Suggested checklist',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'A personalized travel essential checklist to help you pack,\nGenerated using pattern recognition',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 18),

              /// TABS
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  unselectedLabelColor: Colors.white70,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tabs: _tabItems.keys
                      .map((name) => Tab(text: name))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0E12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showAddItemDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: _tabItems.keys.map((tabKey) {
                            final items = _tabItems[tabKey]!;
                            return ListView.builder(
                              itemCount: items.length,
                              padding: const EdgeInsets.only(top: 8, bottom: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final key = '$tabKey|$item';
                                final checked = _checked.contains(key);
                                final isCustom = !_defaultItems[tabKey]!.contains(item);

                                return GestureDetector(
                                  onTap: () => _toggleCheck(key),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF24222C),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: checked
                                                ? Colors.white
                                                : const Color(0xFFFF5B61),
                                            border: Border.all(
                                              color: const Color(0xFFFF5B61),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 16),
                                          ),
                                        ),
                                        if (checked)
                                          const Icon(Icons.check_circle,
                                              color: Colors.white, size: 22),
                                        if (isCustom) ...[
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline,
                                                color: Colors.white54, size: 20),
                                            onPressed: () => _deleteItem(tabKey, item),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}