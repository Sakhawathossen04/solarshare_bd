import '../../models/models.dart';
export '../../models/models.dart';

/// Settlement/billing engine per the doc:
/// consumer rate ৳11/kWh, producer payout ৳9/kWh, other costs ৳1/kWh.
/// remaining = collection - payout - other costs (platform margin before
/// taxes and unmodelled obligations — profit is NOT assumed).
class SettlementResult {
  final double settledKwh;
  final double consumerRate;
  final double producerRate;
  final double otherCostPerKwh;

  const SettlementResult({
    required this.settledKwh,
    required this.consumerRate,
    required this.producerRate,
    required this.otherCostPerKwh,
  });

  double get consumerCollection => settledKwh * consumerRate;
  double get producerPayment => settledKwh * producerRate;
  double get otherCosts => settledKwh * otherCostPerKwh;
  double get remaining =>
      consumerCollection - producerPayment - otherCosts;
}

class AppSession {
  AppUser? user;
  double walletBalance = 0;

  bool get isProducer => user?.role == UserRole.producer;
  bool get isAdmin => user?.role == UserRole.admin;

  /// Demo logins — any email with any password works in the prototype.
  static const AppUser demoProducer = AppUser(
    id: 'U-001',
    name: 'রফিক আহমেদ',
    email: 'rafik@demo.bd',
    area: 'ধানমন্ডি, ঢাকা',
    role: UserRole.producer,
    meterId: 'P-001',
  );
  static const AppUser demoConsumer = AppUser(
    id: 'U-101',
    name: 'সাজিদা খাতুন',
    email: 'sajida@demo.bd',
    area: 'ধানমন্ডি, ঢাকা',
    role: UserRole.consumer,
    meterId: 'C-101',
  );
  static const AppUser demoAdmin = AppUser(
    id: 'U-999',
    name: 'অ্যাডমিন',
    email: 'admin@demo.bd',
    area: 'কেন্দ্রীয়',
    role: UserRole.admin,
    meterId: 'A-000',
  );
}
