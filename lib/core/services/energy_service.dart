import 'dart:math';
import '../../models/models.dart';
import 'session.dart';
import 'sim_data.dart';

/// Central service the screens use to fetch simulated energy data
/// for the currently logged-in user / community.
class EnergyService {
  final AppSession session;
  EnergyService(this.session);

  List<MeterReading> todayHours() {
    if (session.user == null) return [];
    return hourReadings(session.user!, 0);
  }

  List<MeterReading> yesterdayHours() => hourReadings(session.user!, 1);

  /// 7-day solar forecast (kWh/day) — smooth bell curve with mild noise.
  List<double> solarForecast() {
    final r = Random(session.user!.id.hashCode);
    final base = session.isProducer ? 18.0 : 0.0;
    return List.generate(7, (i) {
      final noise = 0.85 + r.nextDouble() * 0.3;
      double v = base * noise;
      if (i == 3) v *= 0.65; // one cloudy day
      if (i == 5) v *= 0.8;
      return v;
    });
  }

  double todayGen() {
    if (session.user == null) return 0;
    double s = 0;
    for (final r in todayHours()) {
      s += r.solarGeneration;
    }
    return s;
  }

  double todaySelfUse() {
    if (session.user == null) return 0;
    double s = 0;
    for (final r in todayHours()) {
      s += r.selfUse;
    }
    return s;
  }

  double todayExport() {
    if (session.user == null) return 0;
    double s = 0;
    for (final r in todayHours()) {
      s += r.gridExport;
    }
    return s;
  }

  double todayImport() {
    if (session.user == null) return 0;
    double s = 0;
    for (final r in todayHours()) {
      s += r.gridImport;
    }
    return s;
  }

  bool meterOnline() {
    if (session.user == null) return true;
    return todayHours().any((r) => r.meterOnline) &&
        todayHours().last.meterOnline;
  }

  double todayEarning() => todayExport() * 9.0; // ৳9/kWh producer payout
  double todaySelfSaving() =>
      todaySelfUse() * 11.0; // ৳11/kWh avoided grid purchase

  /// Local match ratio: surplus that found same-time local demand (demo 62%).
  double matchRatio() => 0.62;

  List<MeterReading> dailyAggregates(int days) {
    if (session.user == null) return [];
    return dayAggregates(session.user!, days);
  }

  List<EnergyOffer> offers() => seedOffers();
  List<Trade> trades() => seedTrades();
  List<WalletTxn> txns() =>
      seedTxns(session.user?.role ?? UserRole.consumer);
  List<SystemAlert> alerts() => seedAlerts();
  List<AreaStat> areaStats() => seedAreaStats();
  List<CommunityMember> community() => seedCommunity();

  SettlementResult settlement(double kwh, {double consumerRate = 11, double producerRate = 9, double other = 1}) =>
      SettlementResult(
        settledKwh: kwh,
        consumerRate: consumerRate,
        producerRate: producerRate,
        otherCostPerKwh: other,
      );
}
