// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/bookmark_provider.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/floating_filter_button.dart';
import '../shared/filter_utils.dart';
import 'tender_detail_screen.dart';
import '../utils/back_button_handler.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Removed draggable button position

  void _openFilter(BuildContext context) async {
    final result = await FilterUtils.openAdvancedFilter(context);
    if (!context.mounted) return;
    if (result != null) {
      final hasSelection = result.values.any((v) => v != null && v.isNotEmpty);
      if (hasSelection) {
        Navigator.pushNamed(
          context,
          '/tenders',
          arguments: {'filters': result},
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

  @override
  Widget build(BuildContext context) {
    // Removed draggable button position logic
    return WillPopScope(
      onWillPop: () => BackButtonHandler.handleMainPageBackPress(context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Favourite Tenders',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1C989C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          onFilterPressed: () => _openFilter(context),
          currentIndex: 2, // Favorites screen is index 2
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, _) {
                  final bookmarks = bookmarkProvider.bookmarkedTenders;
                  if (bookmarks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: 80,
                            color: Color(0xFF1C989C),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your favorite tenders will appear here',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await bookmarkProvider.reloadBookmarks();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarks.length,
                      separatorBuilder: (_, _index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final tender = bookmarks[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              tender.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Tender ID: ${tender.tenderId}'),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.bookmark_remove,
                                color: Color(0xFF1C989C),
                              ),
                              tooltip: 'Remove from Bookmarks',
                              onPressed: () {
                                bookmarkProvider.removeBookmark(tender);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TenderDetailScreen(tender: tender),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // Fixed Floating Filter Button
              FloatingFilterButton(onPressed: () => _openFilter(context)),
            ],
          ),
        ),
      ),
    );
  }
}
