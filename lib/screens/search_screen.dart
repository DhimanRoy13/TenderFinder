// ignore_for_file: use_key_in_widget_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:tenderfinder/widgets/custom_bottom_navbar.dart';
import '../widgets/floating_filter_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void _openFilter(BuildContext context) {
    Navigator.pushNamed(context, '/filter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      bottomNavigationBar: CustomBottomNavBar(
        onFilterPressed: () => _openFilter(context),
        currentIndex: -1, // Search screen not in main tabs
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text(
                "Welcome to Search Page",
                style: TextStyle(fontSize: 24),
              ),
            ),
            // Fixed floating filter button
            FloatingFilterButton(onPressed: () => _openFilter(context)),
          ],
        ),
      ),
    );
  }
}
