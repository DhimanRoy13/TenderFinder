import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionStatus { free, premium, expired }

enum SubscriptionPlan { monthly, quarterly, yearly }

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionStatus _status = SubscriptionStatus.free;
  DateTime? _expiryDate;
  SubscriptionPlan? _currentPlan;
  String? _userId;

  SubscriptionStatus get status => _status;
  DateTime? get expiryDate => _expiryDate;
  SubscriptionPlan? get currentPlan => _currentPlan;
  String? get userId => _userId;

  bool get isSubscribed => _status == SubscriptionStatus.premium && !isExpired;
  bool get isExpired =>
      _expiryDate != null && DateTime.now().isAfter(_expiryDate!);

  // Initialize subscription data
  Future<void> initializeSubscription(String userId) async {
    _userId = userId;
    await _loadSubscriptionData();
    _checkExpiryStatus();
    notifyListeners();
  }

  // Load subscription data from shared preferences
  Future<void> _loadSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    final statusIndex = prefs.getInt('subscription_status') ?? 0;
    _status = SubscriptionStatus.values[statusIndex];

    final expiryTimestamp = prefs.getInt('subscription_expiry');
    if (expiryTimestamp != null) {
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    }

    final planIndex = prefs.getInt('subscription_plan');
    if (planIndex != null) {
      _currentPlan = SubscriptionPlan.values[planIndex];
    }
  }

  // Save subscription data to shared preferences
  Future<void> _saveSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscription_status', _status.index);

    if (_expiryDate != null) {
      await prefs.setInt(
        'subscription_expiry',
        _expiryDate!.millisecondsSinceEpoch,
      );
    }

    if (_currentPlan != null) {
      await prefs.setInt('subscription_plan', _currentPlan!.index);
    }
  }

  // Check if subscription has expired
  void _checkExpiryStatus() {
    if (_status == SubscriptionStatus.premium && isExpired) {
      _status = SubscriptionStatus.expired;
    }
  }

  // Subscribe to a plan
  Future<void> subscribe(SubscriptionPlan plan) async {
    _currentPlan = plan;
    _status = SubscriptionStatus.premium;

    // Set expiry date based on plan
    final now = DateTime.now();
    switch (plan) {
      case SubscriptionPlan.monthly:
        _expiryDate = now.add(const Duration(days: 30));
        break;
      case SubscriptionPlan.quarterly:
        _expiryDate = now.add(const Duration(days: 90));
        break;
      case SubscriptionPlan.yearly:
        _expiryDate = now.add(const Duration(days: 365));
        break;
    }

    await _saveSubscriptionData();
    notifyListeners();
  }

  // Renew subscription
  Future<void> renewSubscription() async {
    if (_currentPlan != null) {
      await subscribe(_currentPlan!);
    }
  }

  // Cancel subscription (mark as expired)
  Future<void> cancelSubscription() async {
    _status = SubscriptionStatus.expired;
    await _saveSubscriptionData();
    notifyListeners();
  }

  // Get remaining days
  int get remainingDays {
    if (_expiryDate == null) return 0;
    final difference = _expiryDate!.difference(DateTime.now());
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  // Get plan details
  Map<String, dynamic> getPlanDetails(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.monthly:
        return {
          'name': 'Monthly Plan',
          'price': '₹299',
          'duration': '30 days',
          'savings': '',
        };
      case SubscriptionPlan.quarterly:
        return {
          'name': 'Quarterly Plan',
          'price': '₹799',
          'duration': '90 days',
          'savings': 'Save 11%',
        };
      case SubscriptionPlan.yearly:
        return {
          'name': 'Yearly Plan',
          'price': '₹2999',
          'duration': '365 days',
          'savings': 'Save 17%',
        };
    }
  }

  // Get features for premium subscription
  List<String> get premiumFeatures => [
    'Unlimited tender access',
    'Advanced search filters',
    'Tender notifications',
    'Download tender documents',
    'Bookmark unlimited tenders',
    'Priority customer support',
    'Export tender data',
    'Tender analytics & insights',
  ];

  // Simulate payment processing (in real app, integrate with payment gateway)
  Future<bool> processPayment(
    SubscriptionPlan plan,
    Map<String, String> paymentDetails,
  ) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would integrate with payment gateways like Razorpay, Stripe, etc.
    // For demo purposes, we'll assume payment is successful
    return true;
  }
}
