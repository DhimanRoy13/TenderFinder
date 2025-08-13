import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/will_pop_scope_state.dart';

class BackButtonHandler {
  /// Handles back button press for main navigation pages
  /// Shows "Press back again to exit" snackbar on first press
  /// Exits app on second press within 2 seconds
  /// Prevents navigation away from main screens
  static Future<bool> handleMainPageBackPress(BuildContext context) async {
    final now = DateTime.now();

    // Check if this is the first press or if enough time has passed
    if (WillPopScopeState.lastBackPress == null ||
        now.difference(WillPopScopeState.lastBackPress!) >
            const Duration(seconds: 2)) {
      // First press - show snackbar and don't exit/navigate
      WillPopScopeState.lastBackPress = now;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        );
      }

      return false; // Don't exit or navigate away from main screens
    }

    // Second press within time limit - exit the app completely
    SystemNavigator.pop();
    return true;
  }

  /// Handles back button press for regular pages
  /// Just pops to previous page normally
  static Future<bool> handleRegularPageBackPress(BuildContext context) async {
    Navigator.of(context).pop();
    return false; // Don't let system handle it
  }
}
