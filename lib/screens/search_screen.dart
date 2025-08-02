// ignore_for_file: use_key_in_widget_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:tenderfinder/widgets/custom_bottom_navbar.dart';

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
            Positioned(
              right: 16,
              bottom: 16,
              child: SizedBox(
                height: 56,
                width: 56,
                child: FloatingActionButton(
                  onPressed: () => _openFilter(context),
                  shape: const CircleBorder(),
                  backgroundColor: Color(0xFF007074),
                  elevation: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.filter_list, size: 28, color: Colors.white),
                      SizedBox(height: 1),
                      Text(
                        'Filter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
