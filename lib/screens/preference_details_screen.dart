import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceDetailsScreen extends StatefulWidget {
  const PreferenceDetailsScreen({super.key});

  @override
  State<PreferenceDetailsScreen> createState() =>
      _PreferenceDetailsScreenState();
}

class _PreferenceDetailsScreenState extends State<PreferenceDetailsScreen> {
  // Track which dropdown is open
  String? _openDropdown;

  Widget _buildInlineMultiSelectDropdown({
    required String label,
    required List<String> options,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
    required IconData icon,
    required TextEditingController controller,
  }) {
    final isOpen = _openDropdown == label;
    final searchController = TextEditingController();
    List<String> filteredOptions = List.from(options);
    return StatefulBuilder(
      builder: (context, setDropState) {
        void filterOptions(String query) {
          setDropState(() {
            filteredOptions = options
                .where((o) => o.toLowerCase().contains(query.toLowerCase()))
                .toList();
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _openDropdown = isOpen ? null : label;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isOpen ? 'Close' : 'Browse',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Icon(
                          isOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isOpen) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: selectedItems
                                        .map(
                                          (item) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF007074,
                                              ).withOpacity(0.13),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF007074),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedItems.remove(
                                                        item,
                                                      );
                                                      onChanged(
                                                        List.from(
                                                          selectedItems,
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 2,
                                                    ),
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 13,
                                                      color: Color(0xFF007074),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: searchController,
                                    onChanged: filterOptions,
                                    decoration: const InputDecoration(
                                      hintText: 'Write to search',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...filteredOptions.map(
                      (option) => CheckboxListTile(
                        title: Text(option),
                        value: selectedItems.contains(option),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              if (!selectedItems.contains(option)) {
                                selectedItems.add(option);
                              }
                            } else {
                              selectedItems.remove(option);
                            }
                            onChanged(List.from(selectedItems));
                          });
                        },
                        activeColor: const Color(0xFF007074),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  final TextEditingController locationController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController tenderTypeController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();
  DateTime? selectedDate;
  bool _loading = true;

  // Dropdown options
  final List<String> categoryOptions = [
    'Construction',
    'IT Services',
    'Healthcare',
    'Education',
    'Transportation',
    'Energy',
    'Agriculture',
  ];
  final List<String> locationOptions = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Chennai',
    'Kolkata',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
  ];
  final List<String> organizationOptions = [
    'Government',
    'Private',
    'PSU',
    'Municipal',
    'State Government',
    'Central Government',
  ];
  final List<String> tenderTypeOptions = [
    'Open Tender',
    'Limited Tender',
    'Single Source',
    'Global Tender',
    'e-Tender',
    'Quotation',
  ];
  final List<String> sectorOptions = [
    'Public',
    'Private',
    'Semi-Government',
    'Autonomous',
    'International',
  ];

  // Selected items for multi-select
  List<String> selectedCategories = [];
  List<String> selectedLocations = [];
  List<String> selectedOrganizations = [];
  List<String> selectedTenderTypes = [];
  List<String> selectedSectors = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      locationController.text = prefs.getString('pref_location') ?? '';
      categoryController.text = prefs.getString('pref_category') ?? '';
      organizationController.text = prefs.getString('pref_organization') ?? '';
      tenderTypeController.text = prefs.getString('pref_tender_type') ?? '';
      sectorController.text = prefs.getString('pref_sector') ?? '';

      // Load selected lists
      selectedCategories =
          prefs.getStringList('pref_selected_categories') ?? [];
      selectedLocations = prefs.getStringList('pref_selected_locations') ?? [];
      selectedOrganizations =
          prefs.getStringList('pref_selected_organizations') ?? [];
      selectedTenderTypes =
          prefs.getStringList('pref_selected_tender_types') ?? [];
      selectedSectors = prefs.getStringList('pref_selected_sectors') ?? [];

      final dateStr = prefs.getString('pref_date');
      if (dateStr != null) {
        selectedDate = DateTime.tryParse(dateStr);
      }
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_location', locationController.text);
    await prefs.setString('pref_category', categoryController.text);
    await prefs.setString('pref_organization', organizationController.text);
    await prefs.setString('pref_tender_type', tenderTypeController.text);
    await prefs.setString('pref_sector', sectorController.text);

    // Save selected lists
    await prefs.setStringList('pref_selected_categories', selectedCategories);
    await prefs.setStringList('pref_selected_locations', selectedLocations);
    await prefs.setStringList(
      'pref_selected_organizations',
      selectedOrganizations,
    );
    await prefs.setStringList(
      'pref_selected_tender_types',
      selectedTenderTypes,
    );
    await prefs.setStringList('pref_selected_sectors', selectedSectors);

    if (selectedDate != null) {
      await prefs.setString('pref_date', selectedDate!.toIso8601String());
    } else {
      await prefs.remove('pref_date');
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preferences saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preference'),
        backgroundColor: const Color(0xFF007074),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter Preferences',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007074),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildInlineMultiSelectDropdown(
                            label: 'Category',
                            options: categoryOptions,
                            selectedItems: selectedCategories,
                            onChanged: (items) => selectedCategories = items,
                            icon: Icons.category,
                            controller: categoryController,
                          ),
                          const SizedBox(height: 16),
                          _buildInlineMultiSelectDropdown(
                            label: 'Location',
                            options: locationOptions,
                            selectedItems: selectedLocations,
                            onChanged: (items) => selectedLocations = items,
                            icon: Icons.location_on,
                            controller: locationController,
                          ),
                          const SizedBox(height: 16),
                          _buildInlineMultiSelectDropdown(
                            label: 'Organization',
                            options: organizationOptions,
                            selectedItems: selectedOrganizations,
                            onChanged: (items) => selectedOrganizations = items,
                            icon: Icons.business,
                            controller: organizationController,
                          ),
                          const SizedBox(height: 16),
                          _buildInlineMultiSelectDropdown(
                            label: 'Tender Type',
                            options: tenderTypeOptions,
                            selectedItems: selectedTenderTypes,
                            onChanged: (items) => selectedTenderTypes = items,
                            icon: Icons.description,
                            controller: tenderTypeController,
                          ),
                          const SizedBox(height: 16),
                          _buildInlineMultiSelectDropdown(
                            label: 'Sector',
                            options: sectorOptions,
                            selectedItems: selectedSectors,
                            onChanged: (items) => selectedSectors = items,
                            icon: Icons.account_tree,
                            controller: sectorController,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: const Icon(Icons.date_range),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText: selectedDate == null
                                      ? 'Select date'
                                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _savePreferences,
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Save Preferences',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007074),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      // FloatingActionButton removed as per request
    );
  }

  @override
  void dispose() {
    locationController.dispose();
    categoryController.dispose();
    organizationController.dispose();
    tenderTypeController.dispose();
    sectorController.dispose();
    super.dispose();
  }
}
