import 'dart:math';

import '../../models/models.dart';

/// Deterministic pseudo-random generator so every launch shows the
/// same believable dataset (like a seeded fixture/demo environment).
final Random _rng = Random(42);

List<AppUser> seedUsers() => [
      const AppUser(
        id: 'U-001',
        name: 'রফিক আহমেদ',
        email: 'rafik@demo.bd',
        area: 'ধানমন্ডি, ঢাকা',
        role: UserRole.producer,
        meterId: 'P-001',
      ),
      const AppUser(
        id: 'U-002',
        name: 'নুসরাত জাহান',
        email: 'nusrat@demo.bd',
        area: 'উত্তরা, ঢাকা',
        role: UserRole.producer,
        meterId: 'P-002',
      ),
      const AppUser(
        id: 'U-003',
        name: 'কামাল হোসেন',
        email: 'kamal@demo.bd',
        area: 'আগ্রাবাদ, চট্টগ্রাম',
        role: UserRole.producer,
        meterId: 'P-003',
      ),
      const AppUser(
        id: 'U-101',
        name: 'সাজিদা খাতুন',
        email: 'sajida@demo.bd',
        area: 'ধানমন্ডি, ঢাকা',
        role: UserRole.consumer,
        meterId: 'C-101',
      ),
      const AppUser(
        id: 'U-102',
        name: 'ইমরান কবির',
        email: 'imran@demo.bd',
        area: 'উত্তরা, ঢাকা',
        role: UserRole.consumer,
        meterId: 'C-102',
      ),
      const AppUser(
        id: 'U-103',
        name: 'তানভীর রানা',
        email: 'tanvir@demo.bd',
        area: 'আগ্রাবাদ, চট্টগ্রাম',
        role: UserRole.consumer,
        meterId: 'C-103',
      ),
    ];

/// Hourly readings for [dayOffset] (0 = today, 1 = yesterday...).
/// Solar bell curve between ~6:00 and ~18:00, household consumption
/// with morning/evening peaks. For producers part of generation is
/// self-used and the surplus is exported.
List<MeterReading> hourReadings(AppUser user, int dayOffset) {
  final now = DateTime.now();
  final day = DateTime(now.year, now.month, now.day - dayOffset);
  final isProducer = user.role == UserRole.producer;
  // Each producer/consumer gets a stable per-user scale.
  final scale = 0.7 + (user.id.hashCode % 60) / 100.0;
  final List<MeterReading> out = [];
  for (int h = 0; h < 24; h++) {
    final ts = DateTime(day.year, day.month, day.day, h);
    // Solar bell curve (6h..18h, peak 12h30).
    final x = (h - 12.5) / 6.0;
    final bell = x.abs() < 1 ? cos(x * pi / 2) : 0.0;
    final solar = isProducer
        ? (2.4 * bell * scale) + ((h % 3) * 0.03) // small noise
        : 0.0;
    // Consumption: base load + morning + evening peak.
    double cons = 0.25 + 0.55 * max(0, cos((h - 19) * pi / 14)) * scale;
    if (h == 7 || h == 8) cons += 0.4;
    if (h == 19 || h == 20) cons += 0.7;
    cons += (_rng.nextDouble() - 0.5) * 0.08;
    cons = cons.clamp(0.05, 1.8);
    final export = isProducer ? max(0, solar - cons) : 0.0;
    final import = max(0, cons - solar);
    out.add(
      MeterReading(
        userId: user.id,
        timestamp: ts,
        solarGeneration: solar,
        consumption: cons,
        gridExport: export,
        gridImport: import,
        meterOnline: !(dayOffset == 0 && h == 4 && user.id == 'U-003'),
      ),
    );
  }
  return out;
}

/// Daily aggregates for last [days] days.
List<MeterReading> dayAggregates(AppUser user, int days) {
  final List<MeterReading> out = [];
  for (int d = 0; d < days; d++) {
    final hours = hourReadings(user, d);
    double s = 0, c = 0, e = 0, i = 0;
    for (final r in hours) {
      s += r.solarGeneration;
      c += r.consumption;
      e += r.gridExport;
      i += r.gridImport;
    }
    out.add(
      MeterReading(
        userId: user.id,
        timestamp: DateTime.now().subtract(Duration(days: d)),
        solarGeneration: s,
        consumption: c,
        gridExport: e,
        gridImport: i,
        meterOnline: true,
      ),
    );
  }
  return out;
}

List<EnergyOffer> seedOffers() {
  final now = DateTime.now();
  List<EnergyOffer> l = [
    EnergyOffer(
      id: 'O-01',
      producerId: 'U-002',
      producerName: 'নুসরাত জাহান',
      area: 'উত্তরা, ঢাকা',
      kwh: 6.0,
      ratePerKwh: 9.0,
      windowStart: now,
      status: OfferStatus.pending,
    ),
    EnergyOffer(
      id: 'O-02',
      producerId: 'U-003',
      producerName: 'কামাল হোসেন',
      area: 'আগ্রাবাদ, চট্টগ্রাম',
      kwh: 4.5,
      ratePerKwh: 8.5,
      windowStart: now.add(const Duration(hours: 2)),
      status: OfferStatus.pending,
    ),
    EnergyOffer(
      id: 'O-03',
      producerId: 'U-001',
      producerName: 'রফিক আহমেদ',
      area: 'ধানমন্ডি, ঢাকা',
      kwh: 3.2,
      ratePerKwh: 9.0,
      windowStart: now.subtract(const Duration(days: 1)),
      status: OfferStatus.settled,
    ),
  ];
  return l;
}

List<Trade> seedTrades() {
  final now = DateTime.now();
  return [
    Trade(
      id: 'T-01',
      offerId: 'O-03',
      producerId: 'U-001',
      consumerId: 'U-101',
      kwh: 3.2,
      ratePerKwh: 9.0,
      settledAt: now.subtract(const Duration(days: 1)),
    ),
    Trade(
      id: 'T-02',
      offerId: 'O-04',
      producerId: 'U-002',
      consumerId: 'U-102',
      kwh: 2.5,
      ratePerKwh: 9.0,
      settledAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}

List<WalletTxn> seedTxns(UserRole role) {
  final now = DateTime.now();
  return [
    WalletTxn(
      id: 'T1',
      title: 'Trade T-01 settlement',
      amount: role == UserRole.producer ? 28.8 : 35.2,
      type: role == UserRole.producer ? TxnType.credit : TxnType.debit,
      date: now.subtract(const Duration(days: 1)),
    ),
    WalletTxn(
      id: 'T1b',
      title: 'Trade T-02 settlement',
      amount: role == UserRole.producer ? 22.5 : 27.5,
      type: role == UserRole.producer ? TxnType.credit : TxnType.debit,
      date: now.subtract(const Duration(days: 2)),
    ),
    WalletTxn(
      id: 'T3',
      title: 'Monthly meter charge',
      amount: 50,
      type: TxnType.debit,
      date: now.subtract(const Duration(days: 3)),
    ),
  ];
}

List<SystemAlert> seedAlerts() {
  final now = DateTime.now();
  return [
    SystemAlert(
      id: 'A-01',
      title: 'Meter offline',
      detail: 'P-003 meter missing readings for 1 interval (04:00).',
      level: AlertLevel.warning,
      time: now.subtract(const Duration(hours: 5)),
    ),
    SystemAlert(
      id: 'A-02',
      title: 'Duplicate reading rejected',
      detail: 'Gateway re-sent interval 12:00 for C-102; duplicate dropped.',
      level: AlertLevel.info,
      time: now.subtract(const Duration(hours: 9)),
    ),
    SystemAlert(
      id: 'A-03',
      title: 'Tamper flag cleared',
      detail: 'P-001 tamper flag cleared after site visit.',
      level: AlertLevel.info,
      time: now.subtract(const Duration(days: 1, hours: 3)),
    ),
  ];
}

List<AreaStat> seedAreaStats() => [
      const AreaStat(
        area: 'ধানমন্ডি, ঢাকা',
        generatedKwh: 128.4,
        consumedKwh: 96.2,
        matchRatio: 0.62,
      ),
      const AreaStat(
        area: 'উত্তরা, ঢাকা',
        generatedKwh: 94.7,
        consumedKwh: 110.5,
        matchRatio: 0.48,
      ),
      const AreaStat(
        area: 'আগ্রাবাদ, চট্টগ্রাম',
        generatedKwh: 71.9,
        consumedKwh: 84.3,
        matchRatio: 0.55,
      ),
    ];

List<CommunityMember> seedCommunity() => [
      const CommunityMember(
        id: 'U-002',
        name: 'নুসরাত জাহান',
        area: 'উত্তরা, ঢাকা',
        role: UserRole.producer,
        kwhToday: 6.0,
        rating: 4.8,
      ),
      const CommunityMember(
        id: 'U-003',
        name: 'কামাল হোসেন',
        area: 'আগ্রাবাদ, চট্টগ্রাম',
        role: UserRole.producer,
        kwhToday: 4.5,
        rating: 4.6,
      ),
      const CommunityMember(
        id: 'U-004',
        name: 'শাহাদাত মোল্লা',
        area: 'মিরপুর, ঢাকা',
        role: UserRole.producer,
        kwhToday: 3.8,
        rating: 4.4,
      ),
      const CommunityMember(
        id: 'U-005',
        name: 'ফারহানা ইসলাম',
        area: 'বনানী, ঢাকা',
        role: UserRole.producer,
        kwhToday: 2.9,
        rating: 4.7,
      ),
    ];
