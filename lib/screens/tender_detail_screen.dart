import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/tender_models.dart';
import '../shared/bookmark_provider.dart';
import '../widgets/custom_bottom_navbar.dart';

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, _) {
          final tender = widget.tender;
          final isBookmarked = bookmarkProvider.isBookmarked(tender);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tender Details'),
              backgroundColor: const Color(0xFF1C989C),
              foregroundColor: Colors.white,
              actions: [
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
              ),
            ),
          );
        },
      ),
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
