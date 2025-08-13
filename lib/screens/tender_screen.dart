// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../shared/tender_models.dart';
import '../shared/tender_widgets.dart';
import '../shared/filter_utils.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/floating_filter_button.dart';
import '../utils/back_button_handler.dart';

// TenderScreen reuses the DashboardScreen logic
class TenderScreen extends StatefulWidget {
  const TenderScreen({super.key});

  @override
  State<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
  late Future<List<Tender>> tendersFuture;
  List<Tender> _allTenders = [];
  List<Tender> _filteredTenders = [];
  Map<String, String?> _selectedFilters = {
    'Category': null,
    'Location': null,
    'Source': null,
    'Organization': null,
    'Tender Type': null,
    'Date': null,
    'Search': null,
  };
  bool _filtersApplied = false;
  // Removed draggable button position

  @override
  void initState() {
    super.initState();
    tendersFuture = fetchTenders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if filters were passed from another screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['filters'] != null) {
      final Map<String, String?> passedFilters = args['filters'];
      setState(() {
        _selectedFilters = Map<String, String?>.from(passedFilters);
        _filtersApplied = true;
      });

      // Apply filters when tenders are loaded
      if (_allTenders.isNotEmpty) {
        _applyFilters();
      }
    }
  }

  Future<List<Tender>> fetchTenders() async {
    // Replace with your actual API endpoint
    final response = await http.get(
      Uri.parse('https://mocki.io/v1/deefa9e3-0d72-4c9e-801a-280b0fbf75b2'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final tenders = data.map((json) => Tender.fromJson(json)).toList();
      _allTenders = tenders;
      _filteredTenders = List.from(_allTenders);

      // Apply filters if they were passed from another screen
      if (_filtersApplied) {
        _applyFilters();
      }

      return _filteredTenders;
    } else {
      throw Exception('Failed to load tenders');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTenders = _allTenders.where((tender) {
        // Category filter
        if (_selectedFilters['Category'] != null &&
            _selectedFilters['Category']!.isNotEmpty) {
          if (!tender.type.toLowerCase().contains(
            _selectedFilters['Category']!.toLowerCase(),
          )) {
            return false;
          }
        }

        // Location filter
        if (_selectedFilters['Location'] != null &&
            _selectedFilters['Location']!.isNotEmpty) {
          if (!tender.place.toLowerCase().contains(
            _selectedFilters['Location']!.toLowerCase(),
          )) {
            return false;
          }
        }

        // Source filter (using inviter as source)
        if (_selectedFilters['Source'] != null &&
            _selectedFilters['Source']!.isNotEmpty) {
          if (!tender.inviter.toLowerCase().contains(
            _selectedFilters['Source']!.toLowerCase(),
          )) {
            return false;
          }
        }

        // Organization filter (using inviter)
        if (_selectedFilters['Organization'] != null &&
            _selectedFilters['Organization']!.isNotEmpty) {
          if (!tender.inviter.toLowerCase().contains(
            _selectedFilters['Organization']!.toLowerCase(),
          )) {
            return false;
          }
        }

        // Tender Type filter
        if (_selectedFilters['Tender Type'] != null &&
            _selectedFilters['Tender Type']!.isNotEmpty) {
          if (!tender.type.toLowerCase().contains(
            _selectedFilters['Tender Type']!.toLowerCase(),
          )) {
            return false;
          }
        }

        // Search filter (searches in title, inviter, and place)
        if (_selectedFilters['Search'] != null &&
            _selectedFilters['Search']!.isNotEmpty) {
          final searchTerm = _selectedFilters['Search']!.toLowerCase();
          if (!tender.title.toLowerCase().contains(searchTerm) &&
              !tender.inviter.toLowerCase().contains(searchTerm) &&
              !tender.place.toLowerCase().contains(searchTerm) &&
              !tender.tenderId.toLowerCase().contains(searchTerm)) {
            return false;
          }
        }

        // Date filter
        if (_selectedFilters['Date'] != null &&
            _selectedFilters['Date']!.isNotEmpty) {
          try {
            final dateRange = _selectedFilters['Date']!.split(' - ');
            if (dateRange.length == 2) {
              final startDate = DateTime.parse(
                _convertDateFormat(dateRange[0]),
              );
              final endDate = DateTime.parse(_convertDateFormat(dateRange[1]));
              final publishedDate = DateTime.parse(
                _convertDateFormat(tender.publishedOn),
              );

              if (publishedDate.isBefore(startDate) ||
                  publishedDate.isAfter(endDate)) {
                return false;
              }
            }
          } catch (e) {
            // If date parsing fails, ignore this filter
          }
        }

        return true;
      }).toList();
    });
  }

  String _convertDateFormat(String date) {
    // Convert MM/DD/YYYY to YYYY-MM-DD
    final parts = date.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
    }
    return date;
  }

  void _openFilterModal() async {
    final result = await FilterUtils.openAdvancedFilter(
      context,
      initialFilters: _selectedFilters,
    );
    if (result != null) {
      final hasSelection = result.values.any((v) => v != null && v.isNotEmpty);
      if (hasSelection) {
        setState(() {
          _selectedFilters = Map<String, String?>.from(result);
          _filtersApplied = true;
        });
        _applyFilters();

        // Show a snackbar to indicate filters were applied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Filters applied - ${_filteredTenders.length} tenders found',
            ),
            backgroundColor: const Color(0xFF1C989C),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No Filters Selected'),
            content: const Text(
              'Please select at least one filter before applying.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Helper to convert MM/DD/YYYY to YYYY-MM-DD for DateTime.parse

  @override
  Widget build(BuildContext context) {
    // Removed draggable button position logic
    return WillPopScope(
      onWillPop: () => BackButtonHandler.handleMainPageBackPress(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            _filtersApplied
                ? 'Filtered Tenders (${_filteredTenders.length})'
                : 'Find Tenders',
          ),
          backgroundColor: const Color(0xFF1C989C),
          foregroundColor: Colors.white,
          actions: _filtersApplied
              ? [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear Filters',
                    onPressed: () {
                      setState(() {
                        _selectedFilters = {
                          'Category': null,
                          'Location': null,
                          'Source': null,
                          'Organization': null,
                          'Tender Type': null,
                          'Date': null,
                          'Search': null,
                        };
                        _filtersApplied = false;
                        _filteredTenders = List.from(_allTenders);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filters cleared'),
                          backgroundColor: Color(0xFF1C989C),
                        ),
                      );
                    },
                  ),
                ]
              : null,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          onFilterPressed: _openFilterModal,
          currentIndex: 1, // Tenders screen is index 1
        ),
        body: SafeArea(
          child: Stack(
            children: [
              FutureBuilder<List<Tender>>(
                future: tendersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No tenders found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        tendersFuture = fetchTenders();
                      });
                      await tendersFuture;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTenders.length,
                      separatorBuilder: (_, _index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          TenderCard(tender: _filteredTenders[index]),
                    ),
                  );
                },
              ),
              // Fixed Floating Filter Button
              FloatingFilterButton(onPressed: _openFilterModal),
            ],
          ),
        ),
      ),
    );
  }
}
