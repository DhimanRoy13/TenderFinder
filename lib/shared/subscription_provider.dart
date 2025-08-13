import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SubscriptionStatus { free, premium, expired }

enum SubscriptionPlan { free, threeMonths, sixMonths, yearly, twoYears }

class SubscriptionProvider extends ChangeNotifier {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
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

  // Load subscription data from secure storage
  Future<void> _loadSubscriptionData() async {
    final statusString = await _secureStorage.read(key: 'subscription_status');
    if (statusString != null) {
      final statusIndex = int.tryParse(statusString) ?? 0;
      _status = SubscriptionStatus.values[statusIndex];
    }

    final expiryString = await _secureStorage.read(key: 'subscription_expiry');
    if (expiryString != null) {
      final expiryTimestamp = int.tryParse(expiryString);
      if (expiryTimestamp != null) {
        _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      }
    }

    final planString = await _secureStorage.read(key: 'subscription_plan');
    if (planString != null) {
      final planIndex = int.tryParse(planString);
      if (planIndex != null) {
        _currentPlan = SubscriptionPlan.values[planIndex];
      }
    }
  }

  // Save subscription data to secure storage
  Future<void> _saveSubscriptionData() async {
    await _secureStorage.write(
      key: 'subscription_status',
      value: _status.index.toString(),
    );

    if (_expiryDate != null) {
      await _secureStorage.write(
        key: 'subscription_expiry',
        value: _expiryDate!.millisecondsSinceEpoch.toString(),
      );
    }

    if (_currentPlan != null) {
      await _secureStorage.write(
        key: 'subscription_plan',
        value: _currentPlan!.index.toString(),
      );
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
      case SubscriptionPlan.free:
        _expiryDate = now.add(const Duration(days: 30));
        break;
      case SubscriptionPlan.threeMonths:
        _expiryDate = now.add(const Duration(days: 90));
        break;
      case SubscriptionPlan.sixMonths:
        _expiryDate = now.add(const Duration(days: 180));
        break;
      case SubscriptionPlan.yearly:
        _expiryDate = now.add(const Duration(days: 365));
        break;
      case SubscriptionPlan.twoYears:
        _expiryDate = now.add(const Duration(days: 730));
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
      case SubscriptionPlan.free:
        return {
          'name': 'Free Trial',
          'price': '৳0',
          'duration': '30 days',
          'savings': 'Try for Free',
        };
      case SubscriptionPlan.threeMonths:
        return {
          'name': '3 Months Plan',
          'price': '৳799',
          'duration': '90 days',
          'savings': 'Save 10%',
        };
      case SubscriptionPlan.sixMonths:
        return {
          'name': '6 Months Plan',
          'price': '৳1499',
          'duration': '180 days',
          'savings': 'Save 15%',
        };
      case SubscriptionPlan.yearly:
        return {
          'name': '12 Months Plan',
          'price': '৳2999',
          'duration': '365 days',
          'savings': 'Save 20%',
        };
      case SubscriptionPlan.twoYears:
        return {
          'name': '24 Months Plan',
          'price': '৳4999',
          'duration': '730 days',
          'savings': 'Save 30%',
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
