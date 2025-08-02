import 'package:flutter/material.dart';
import 'tender_models.dart';

class BookmarkProvider extends ChangeNotifier {
  final List<Tender> _bookmarkedTenders = [];

  List<Tender> get bookmarkedTenders => List.unmodifiable(_bookmarkedTenders);

  bool isBookmarked(Tender tender) {
    return _bookmarkedTenders.any((t) => t.tenderId == tender.tenderId);
  }

  void addBookmark(Tender tender) {
    if (!isBookmarked(tender)) {
      _bookmarkedTenders.add(tender);
      notifyListeners();
    }
  }

  void removeBookmark(Tender tender) {
    _bookmarkedTenders.removeWhere((t) => t.tenderId == tender.tenderId);
    notifyListeners();
  }
}
