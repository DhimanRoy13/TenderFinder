// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'tender_models.dart';
import '../screens/tender_detail_screen.dart';

// Multi-select dropdown for Category filter with chips, scroll, and add
class _MultiSelectCategoryDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const _MultiSelectCategoryDropdown({
    required this.label,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_MultiSelectCategoryDropdown> createState() =>
      _MultiSelectCategoryDropdownState();
}

class _MultiSelectCategoryDropdownState
    extends State<_MultiSelectCategoryDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _expandAnimation;
  late List<String> _selected;
  late List<String> _options;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _selected = List<String>.from(widget.selected);
    _options = List<String>.from(widget.options);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onOptionTap(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
    widget.onChanged(_selected);
  }

  void _removeChip(String value) {
    setState(() {
      _selected.remove(value);
    });
    widget.onChanged(_selected);
  }

  void _addOption(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (!_options.contains(trimmed)) {
      setState(() {
        _options.add(trimmed);
      });
    }
    if (!_selected.contains(trimmed)) {
      setState(() {
        _selected.add(trimmed);
      });
      widget.onChanged(_selected);
    }
    _searchController.clear();
    setState(() {
      _searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = _options
        .where(
          (option) =>
              !_selected.contains(option) &&
              _searchText.isNotEmpty &&
              option.toLowerCase().contains(_searchText.toLowerCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar with dynamic label and icon
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C989C), Color(0xFF007074)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? 'Close' : 'Browse',
                        style: const TextStyle(
                          color: Color(0xFF1C989C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF1C989C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Combined search and select field (when expanded)
        if (_isExpanded)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field with chips inside
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      ..._selected.map(
                        (e) => Chip(
                          label: Text(e, style: const TextStyle(fontSize: 13)),
                          backgroundColor: const Color(0xFFE6F4F1),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                          onDeleted: () => _removeChip(e),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: FocusScope(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search categories...',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 4,
                              ),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (val) {
                              setState(() {
                                _searchText = val;
                              });
                            },
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty &&
                                  !suggestions.contains(val.trim()) &&
                                  !_selected.contains(val.trim())) {
                                _addOption(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Suggestions dropdown
                if (suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView(
                      shrinkWrap: true,
                      children: suggestions.map((option) {
                        return ListTile(
                          title: Text(
                            option,
                            style: const TextStyle(fontSize: 15),
                          ),
                          onTap: () {
                            _addOption(option);
                          },
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ),
                // Main checkbox list (only if no suggestions or search is empty)
                if (suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      height: 180,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          shrinkWrap: true,
                          children: _options
                              .where(
                                (option) =>
                                    _searchText.isEmpty ||
                                    option.toLowerCase().contains(
                                      _searchText.toLowerCase(),
                                    ),
                              )
                              .map((option) {
                                return CheckboxListTile(
                                  value: _selected.contains(option),
                                  onChanged: (checked) => _onOptionTap(option),
                                  title: Text(
                                    option,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class TenderCard extends StatelessWidget {
  final Tender tender;
  const TenderCard({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tender.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF23263B),
                      ),
                    ),
                    const SizedBox(height: 1),
                    InfoRow(
                      label: 'Tender ID',
                      value: tender.tenderId,
                      fontSize: 11,
                    ),
                    InfoRow(label: 'Type', value: tender.type, fontSize: 11),
                    InfoRow(
                      label: 'Inviter',
                      value: tender.inviter,
                      fontSize: 11,
                    ),
                    InfoRow(
                      label: 'Doc. Price',
                      value: tender.docPrice,
                      fontSize: 11,
                    ),
                    InfoRow(
                      label: 'Security Amt.',
                      value: tender.securityAmt,
                      fontSize: 11,
                    ),
                    InfoRow(
                      label: 'Published On',
                      value: tender.publishedOn,
                      fontSize: 11,
                    ),
                    InfoRow(
                      label: 'Closed On',
                      value: tender.closedOn,
                      fontSize: 11,
                    ),
                    InfoRow(
                      label: 'Location',
                      value: tender.place,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
              // Place label is now shown above with InfoRow for consistency
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF1A6D6C),
                ),
                label: Text(
                  tender.daysRemaining,
                  style: const TextStyle(
                    color: Color(0xFF1A6D6C),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6F4F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(color: Color(0xFF1A6D6C)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(color: Color(0xFF1A6D6C)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  tender.alsoPublishedOn,
                  style: const TextStyle(
                    color: Color(0xFF1A6D6C),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TenderDetailScreen(tender: tender),
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    elevation: WidgetStateProperty.all(0),
                  ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1C989C), Color(0xFF085759)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 0),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    'Click Here To See Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<_FilterDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectOption(String option) {
    widget.onChanged(option);
    _toggleDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1C989C), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(widget.icon, color: const Color(0xFF1C989C)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.value ?? widget.label,
                      style: TextStyle(
                        color: widget.value != null
                            ? Colors.black
                            : const Color(0xFF1C989C),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF1C989C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: const Color(0xFF1C989C), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: widget.options.map((option) {
                return InkWell(
                  onTap: () => _selectOption(option),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF1C989C).withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 36), // Align with icon + spacing
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRangePicker extends StatefulWidget {
  final void Function(String?)? onDateRangeChanged;
  final String? initialRange;
  final Color? selectedTextColor;
  const _DateRangePicker({
    this.onDateRangeChanged,
    this.initialRange,
    this.selectedTextColor,
  });
  @override
  State<_DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<_DateRangePicker> {
  DateTimeRange? _selectedRange;
  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null && widget.initialRange!.contains(' - ')) {
      final parts = widget.initialRange!.split(' - ');
      if (parts.length == 2) {
        try {
          final start = _parseDate(parts[0]);
          final end = _parseDate(parts[1]);
          if (start != null && end != null) {
            _selectedRange = DateTimeRange(start: start, end: end);
          }
        } catch (_) {}
      }
    }
  }

  DateTime? _parseDate(String input) {
    final parts = input.trim().split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 5),
              initialDateRange: _selectedRange,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF1C989C),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                      surface: Colors.white,
                      secondary: Color(0xFF1C989C),
                    ),
                    textTheme: const TextTheme(
                      bodyLarge: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                      bodyMedium: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                      bodySmall: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                      titleMedium: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedRange = picked;
              });
              if (widget.onDateRangeChanged != null) {
                final rangeString =
                    '${picked.start.month}/${picked.start.day}/${picked.start.year} - '
                    '${picked.end.month}/${picked.end.day}/${picked.end.year}';
                widget.onDateRangeChanged!(rangeString);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C989C), Color(0xFF007074)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedRange == null
                        ? 'Select date range'
                        : '${_selectedRange!.start.month}/${_selectedRange!.start.day}/${_selectedRange!.start.year} - ${_selectedRange!.end.month}/${_selectedRange!.end.day}/${_selectedRange!.end.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenFilter extends StatefulWidget {
  final Map<String, String?> initialFilters;
  const FullScreenFilter({super.key, required this.initialFilters});
  @override
  State<FullScreenFilter> createState() => FullScreenFilterState();
}

class FullScreenFilterState extends State<FullScreenFilter> {
  late Map<String, String?> _filters;
  String? _dateRangeString;
  final TextEditingController _textFilterController = TextEditingController();
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, String?>.from(widget.initialFilters);
    _dateRangeString = _filters['Date'];
    _textFilterController.text = _filters['Search'] ?? '';
    // Parse initial categories if any
    if (_filters['Category'] != null && _filters['Category']!.isNotEmpty) {
      _selectedCategories = _filters['Category']!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  @override
  void dispose() {
    _textFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top:
                kToolbarHeight +
                MediaQuery.of(context).padding.top +
                30, // 10px below app bar
            left: 0,
            right: 0,
            bottom: 0,
            child: DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.3,
              maxChildSize: 1.0,
              expand: false,
              builder: (context, scrollController) {
                return GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! > 300) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontFamily: 'Poppins'),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 4),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Filter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFF007074),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1C989C),
                                          Color(0xFF007074),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: _textFilterController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Search tenders...',
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                      cursorColor: Colors.white,
                                      onChanged: (value) {
                                        setState(() {
                                          _filters['Search'] = value.isEmpty
                                              ? null
                                              : value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _MultiSelectCategoryDropdown(
                                    label: 'Category',
                                    icon: Icons.category,
                                    options: const [
                                      'Subcategory 1',
                                      'Subcategory 2',
                                      'Subcategory 3',
                                      'Subcategory 4',
                                      'Subcategory 5',
                                      'Subcategory 6',
                                      'Subcategory 7',
                                      'Subcategory 8',
                                    ],
                                    selected: _selectedCategories,
                                    onChanged: (selected) {
                                      setState(() {
                                        _selectedCategories = selected;
                                        _filters['Category'] = selected.join(
                                          ', ',
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _MultiSelectCategoryDropdown(
                                    label: 'Location',
                                    icon: Icons.location_on,
                                    options: const ['City 1', 'City 2'],
                                    selected:
                                        _filters['Location'] == null ||
                                            _filters['Location']!.isEmpty
                                        ? []
                                        : _filters['Location']!
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList(),
                                    onChanged: (selected) {
                                      setState(() {
                                        _filters['Location'] = selected.join(
                                          ', ',
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _MultiSelectCategoryDropdown(
                                    label: 'Source',
                                    icon: Icons.person,
                                    options: const ['Source 1', 'Source 2'],
                                    selected:
                                        _filters['Source'] == null ||
                                            _filters['Source']!.isEmpty
                                        ? []
                                        : _filters['Source']!
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList(),
                                    onChanged: (selected) {
                                      setState(() {
                                        _filters['Source'] = selected.join(
                                          ', ',
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _MultiSelectCategoryDropdown(
                                    label: 'Organization',
                                    icon: Icons.business,
                                    options: const ['Org 1', 'Org 2'],
                                    selected:
                                        _filters['Organization'] == null ||
                                            _filters['Organization']!.isEmpty
                                        ? []
                                        : _filters['Organization']!
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList(),
                                    onChanged: (selected) {
                                      setState(() {
                                        _filters['Organization'] = selected
                                            .join(', ');
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _MultiSelectCategoryDropdown(
                                    label: 'Tender Type',
                                    icon: Icons.settings,
                                    options: const ['Type 1', 'Type 2'],
                                    selected:
                                        _filters['Tender Type'] == null ||
                                            _filters['Tender Type']!.isEmpty
                                        ? []
                                        : _filters['Tender Type']!
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList(),
                                    onChanged: (selected) {
                                      setState(() {
                                        _filters['Tender Type'] = selected.join(
                                          ', ',
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _DateRangePicker(
                                    onDateRangeChanged: (rangeString) {
                                      setState(() {
                                        _dateRangeString = rangeString;
                                        _filters['Date'] = rangeString;
                                      });
                                    },
                                    initialRange: _dateRangeString,
                                    selectedTextColor: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ).copyWith(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.transparent,
                                              ),
                                          elevation: WidgetStateProperty.all(0),
                                        ),
                                    onPressed: () {
                                      Navigator.of(context).pop(_filters);
                                    },
                                    child: Ink(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1C989C),
                                            Color(0xFF007074),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: const Text(
                                          'Apply',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
