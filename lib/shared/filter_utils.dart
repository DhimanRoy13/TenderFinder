import 'package:flutter/material.dart';
import 'tender_widgets.dart';

// Custom PageRoute for smooth bottom-to-top animation
class FadeInBottomRightRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  FadeInBottomRightRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutQuart,
            reverseCurve: Curves.easeInQuart,
          );

          // Smooth bottom to top slide animation
          final offsetTween = Tween<Offset>(
            begin: const Offset(0, 1), // Start from bottom
            end: Offset.zero,
          );
          final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

          return SlideTransition(
            position: offsetTween.animate(curved),
            child: FadeTransition(
              opacity: fadeTween.animate(curved),
              child: child,
            ),
          );
        },
        opaque: false,
        barrierColor: const Color(0x66000000),
        barrierDismissible: false,
      );
}

class FilterUtils {
  static Future<Map<String, String?>?> openAdvancedFilter(
    BuildContext context, {
    Map<String, String?> initialFilters = const {},
  }) async {
    return await Navigator.of(context).push<Map<String, String?>>(
      FadeInBottomRightRoute(
        child: FullScreenFilter(initialFilters: initialFilters),
      ),
    );
  }
}
