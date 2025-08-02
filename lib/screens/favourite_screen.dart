// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/bookmark_provider.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../shared/filter_utils.dart';
import 'tender_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  DateTime? _lastBackPressed;
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
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final tender = bookmarks[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            tender.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                  );
                },
              ),
              // Fixed Floating Filter Button
              Positioned(right: 16, bottom: 16, child: _buildFilterButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      height: 56,
      width: 56,
      child: FloatingActionButton(
        onPressed: () => _openFilter(context),
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF007074),
        foregroundColor: Colors.white,
        splashColor: const Color(0xFF1C989C),
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
    );
  }
}
