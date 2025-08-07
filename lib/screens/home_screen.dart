// lib/screens/home_screen.dart
// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/floating_filter_button.dart';
import '../shared/filter_utils.dart';
import '../shared/tender_models.dart';
import '../shared/tender_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String? userName;
  final bool showWelcome;
  const HomeScreen({
    super.key,
    required this.userEmail,
    this.userName,
    this.showWelcome = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _applyFilters() {
    setState(() {
      _filteredTenders = _allTenders.where((tender) {
        if (_selectedFilters['Category'] != null &&
            _selectedFilters['Category']!.isNotEmpty) {
          if (!tender.type.toLowerCase().contains(
            _selectedFilters['Category']!.toLowerCase(),
          )) {
            return false;
          }
        }
        if (_selectedFilters['Location'] != null &&
            _selectedFilters['Location']!.isNotEmpty) {
          if (!tender.place.toLowerCase().contains(
            _selectedFilters['Location']!.toLowerCase(),
          )) {
            return false;
          }
        }
        if (_selectedFilters['Source'] != null &&
            _selectedFilters['Source']!.isNotEmpty) {
          if (!tender.inviter.toLowerCase().contains(
            _selectedFilters['Source']!.toLowerCase(),
          )) {
            return false;
          }
        }
        if (_selectedFilters['Organization'] != null &&
            _selectedFilters['Organization']!.isNotEmpty) {
          if (!tender.inviter.toLowerCase().contains(
            _selectedFilters['Organization']!.toLowerCase(),
          )) {
            return false;
          }
        }
        if (_selectedFilters['Tender Type'] != null &&
            _selectedFilters['Tender Type']!.isNotEmpty) {
          if (!tender.type.toLowerCase().contains(
            _selectedFilters['Tender Type']!.toLowerCase(),
          )) {
            return false;
          }
        }
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
          } catch (e) {}
        }
        return true;
      }).toList();
    });
  }

  String _convertDateFormat(String date) {
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

  DateTime? _lastBackPressed;
  bool _welcomeShown = false;
  // Removed draggable button position

  @override
  void initState() {
    super.initState();
    tendersFuture = fetchTenders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_welcomeShown && widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome, ${widget.userName ?? widget.userEmail}"),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          );
        }
      });
      _welcomeShown = true;
    }
  }

  Future<List<Tender>> fetchTenders() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://mocki.io/v1/deefa9e3-0d72-4c9e-801a-280b0fbf75b2',
            ),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tenders = data.map((json) => Tender.fromJson(json)).toList();
        _allTenders = tenders;
        if (_filtersApplied) {
          _applyFilters();
        } else {
          _filteredTenders = List.from(_allTenders);
        }
        return _filteredTenders;
      } else {
        throw Exception(
          'Failed to load tenders. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching tenders: $e');
      _allTenders = [];
      _filteredTenders = [];
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: _filtersApplied
              ? Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'TenderFinder',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    TextButton.icon(
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
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                )
              : Image.network(
                  'https://i.postimg.cc/VNHNQ3H1/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
          backgroundColor: const Color(0xFF1C989C),
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          onFilterPressed: _openFilterModal,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              FutureBuilder<List<Tender>>(
                future: tendersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading tenders...'),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Network Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Please check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                tendersFuture = fetchTenders();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No tenders found.'),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTenders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => RepaintBoundary(
                      child: TenderCard(tender: _filteredTenders[index]),
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
