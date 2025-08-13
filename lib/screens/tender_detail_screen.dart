import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/tender_models.dart';
import '../shared/bookmark_provider.dart';
import '../shared/subscription_provider.dart';
import '../screens/subscription_screen.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void openFilter(BuildContext context) async {
  Navigator.pushNamed(context, '/filter');
}

class TenderDetailScreen extends StatefulWidget {
  final Tender tender;
  const TenderDetailScreen({super.key, required this.tender});

  @override
  State<TenderDetailScreen> createState() => _TenderDetailScreenState();
}

class _TenderDetailScreenState extends State<TenderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Check subscription status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSubscriptionAccess();
    });
  }

  void _checkSubscriptionAccess() {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    if (!subscriptionProvider.isSubscribed) {
      // User doesn't have active subscription, redirect to subscription screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionScreen(isFromTenderAccess: true),
        ),
      );
    }
  }

  Future<void> _downloadImage(String imageUrl, String fileName) async {
    try {
      // Check if image URL is valid
      if (imageUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image available to download'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to download images',
              ),
            ),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading image...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get the Downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image saved to Downloads folder'),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        throw Exception(
          'Failed to download image (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookmarkProvider, SubscriptionProvider>(
      builder: (context, bookmarkProvider, subscriptionProvider, _) {
        // If not subscribed, show subscription prompt
        if (!subscriptionProvider.isSubscribed) {
          return const SubscriptionScreen(isFromTenderAccess: true);
        }

        final tender = widget.tender;
        final isBookmarked = bookmarkProvider.isBookmarked(tender);

        return WillPopScope(
          onWillPop: () async {
            final routes = Navigator.of(context);
            bool goHome = false;
            routes.popUntil((route) {
              final name = route.settings.name;
              if (name == '/login' || name == '/signup') {
                goHome = true;
              }
              return true;
            });
            if (goHome) {
              Navigator.of(context).pushReplacementNamed('/splash');
              return false;
            } else {
              Navigator.of(context).pop();
              return true;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Tender Details'),
              backgroundColor: const Color(0xFF1C989C),
              foregroundColor: Colors.white,
              actions: [
                // Download button - only show if tender has an image
                if (tender.image.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    tooltip: 'Download Image',
                    onPressed: () {
                      final fileName = 'tender_${tender.tenderId}_image.jpg';
                      _downloadImage(tender.image, fileName);
                    },
                  ),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  tooltip: isBookmarked ? 'Remove Bookmark' : 'Add to Bookmark',
                  onPressed: () {
                    if (isBookmarked) {
                      bookmarkProvider.removeBookmark(tender);
                    } else {
                      bookmarkProvider.addBookmark(tender);
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 110),
                children: [
                  Text(
                    tender.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C989C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned(
                            left: constraints.maxWidth * 0.38,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.5),
                                1: FlexColumnWidth(2.5),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              children: [
                                _tableRow('Tender ID', tender.tenderId),
                                _tableRow('Type', tender.type),
                                _tableRow('Inviter', tender.inviter),
                                _tableRow('Doc. Price', tender.docPrice),
                                _tableRow('Security Amt', tender.securityAmt),
                                _tableRow('Published On', tender.publishedOn),
                                _tableRow('Closed On', tender.closedOn),
                                _tableRow('Place', tender.place),
                                _tableRow(
                                  'Days Remaining',
                                  tender.daysRemaining,
                                ),
                                _tableRow(
                                  'Also Published On',
                                  tender.alsoPublishedOn,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (tender.image.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, _, __) =>
                                _ImageLightbox(imageUrl: tender.image),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          tender.image,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: CustomBottomNavBar(
                onFilterPressed: () => openFilter(context),
                currentIndex: -1, // Detail screen not in main tabs
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class _ImageLightbox extends StatefulWidget {
  final String imageUrl;
  const _ImageLightbox({required this.imageUrl});

  @override
  State<_ImageLightbox> createState() => _ImageLightboxState();
}

class _ImageLightboxState extends State<_ImageLightbox> {
  double _verticalDrag = 0.0;
  static const double _closeDragThreshold = 90.0;
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dragPercent = (_verticalDrag.abs() / _closeDragThreshold)
        .clamp(0.0, 1.0);
    final double opacity = 1.0 - dragPercent * 0.6;
    final double translateY = _verticalDrag;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95 * opacity),
      body: GestureDetector(
        onDoubleTapDown: (details) {
          _doubleTapDetails = details;
        },
        onDoubleTap: () {
          final position = _doubleTapDetails?.localPosition;
          if (position == null) return;
          final currentScale = _transformationController.value
              .getMaxScaleOnAxis();
          if (currentScale > 1.1) {
            _transformationController.value = Matrix4.identity();
          } else {
            const zoom = 2.5;
            final x = -position.dx * (zoom - 1);
            final y = -position.dy * (zoom - 1);
            _transformationController.value = Matrix4.identity()
              ..translate(x, y)
              ..scale(zoom);
          }
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _verticalDrag += details.delta.dy;
          });
        },
        onVerticalDragEnd: (details) {
          if (_verticalDrag.abs() > _closeDragThreshold) {
            Navigator.of(context).pop();
          }
          setState(() {
            _verticalDrag = 0.0;
          });
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 80),
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
