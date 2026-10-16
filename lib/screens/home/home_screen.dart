import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/energy_service.dart';
import '../../core/services/session.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  final AppSession session;
  const HomeScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final svc = EnergyService(session);
    final isProducer = session.isProducer;
    final hour = DateTime.now().hour;
    final greet = hour < 12 ? AppLocale.t('goodMorning') : AppLocale.t('goodEvening');
    final meterOnline = svc.meterOnline();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting + logo mark
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(color: AppColors.teal50),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greet, ${session.user!.name}!',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.teal900)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.inkSoft),
                          const SizedBox(width: 4),
                          Text(session.user!.area,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.inkSoft)),
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.wifi_tethering,
                        color: meterOnline ? AppColors.success : AppColors.danger,
                        size: 22,
                      ),
                      Text(
                        '${AppLocale.t('meterStatus')}: ${meterOnline ? AppLocale.t('online') : AppLocale.t('offline')}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: meterOnline ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero generation / consumption card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.teal700, AppColors.teal500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isProducer
                              ? AppLocale.t('todayGeneration')
                              : AppLocale.t('consumption'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(isProducer ? svc.todayGen() : svc.todayImport() + svc.todaySelfUse()).toStringAsFixed(2)} kWh',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MiniStat(
                              label: AppLocale.t('selfUse'),
                              value: '${svc.todaySelfUse().toStringAsFixed(1)} kWh',
                            ),
                            _MiniStat(
                              label: AppLocale.t('exported'),
                              value: '${svc.todayExport().toStringAsFixed(1)} kWh',
                            ),
                            _MiniStat(
                              label: AppLocale.t('imported'),
                              value: '${svc.todayImport().toStringAsFixed(1)} kWh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: isProducer
                              ? AppLocale.t('todayEarning')
                              : AppLocale.t('todaySavings'),
                          value:
                              '৳ ${(isProducer ? svc.todayEarning() : svc.todaySelfSaving()).toStringAsFixed(2)}',
                          icon: Icons.savings_outlined,
                          accent: AppColors.amber500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          label: AppLocale.t('matchRatio'),
                          value: '${(svc.matchRatio() * 100).toStringAsFixed(0)}%',
                          icon: Icons.balance_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(AppLocale.t('energyHistory'), icon: Icons.history),
                  const SizedBox(height: 10),
                  _HourChart(hours: svc.todayHours()),
                  const SizedBox(height: 24),
                  // 7-day solar forecast
                  SectionTitle(AppLocale.t('forecast7d'), icon: Icons.wb_sunny_outlined),
                  const SizedBox(height: 10),
                  _ForecastStrip(forecast: svc.solarForecast()),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.cloud_outlined, size: 14, color: AppColors.inkSoft),
                    const SizedBox(width: 6),
                    Text(AppLocale.t('weatherNote'),
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  ]),
                  const SizedBox(height: 24),
                  // demo disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.amber100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline, size: 18, color: Color(0xFF9A6B18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(AppLocale.t('projectNote'),
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFF6B5A1E), height: 1.5)),
                      ),
                      const SizedBox(width: 8),
                      const SimBadge(),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _HourChart extends StatelessWidget {
  final List<MeterReading> hours;
  const _HourChart({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: SizedBox(
        height: 170,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(fontSize: 9, color: AppColors.inkSoft)),
                ),
              ),
            ),
            barGroups: List.generate(hours.length, (i) {
              final h = hours[i];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: h.solarGeneration,
                    width: 6,
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [AppColors.teal500, AppColors.teal700],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  BarChartRodData(
                    toY: h.consumption,
                    width: 6,
                    borderRadius: BorderRadius.circular(3),
                    color: AppColors.amber500,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ForecastStrip extends StatelessWidget {
  final List<double> forecast;
  const _ForecastStrip({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final days = AppLocale.isBn
        ? ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final todayIdx = DateTime.now().weekday % 7;
    final maxV = forecast.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: Row(
        children: List.generate(7, (i) {
          final dayIdx = (todayIdx + i) % 7;
          final v = forecast[i];
          return Expanded(
            child: Column(
              children: [
                Text('${v.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.ink)),
                const SizedBox(height: 6),
                Container(
                  width: 18,
                  height: 60 * (v / maxV),
                  decoration: BoxDecoration(
                    color: v < maxV * 0.7 ? AppColors.inkSoft.withOpacity(0.4) : AppColors.amber500,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(days[dayIdx],
                    style: const TextStyle(fontSize: 10, color: AppColors.inkSoft)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
