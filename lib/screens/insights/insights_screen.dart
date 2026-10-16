import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/energy_service.dart';
import '../../core/services/session.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';

class InsightsScreen extends StatefulWidget {
  final AppSession session;
  const InsightsScreen({super.key, required this.session});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _range = 1; // 0 hour, 1 day, 2 month, 3 year
  bool _showExport = true;

  @override
  Widget build(BuildContext context) {
    final svc = EnergyService(widget.session);
    final isProducer = widget.session.isProducer;

    List<double> gen = [], cons = [], imp = [];
    if (_range == 0) {
      for (final r in svc.todayHours()) {
        gen.add(r.solarGeneration);
        cons.add(r.consumption);
        imp.add(r.gridImport);
      }
    } else if (_range == 1) {
      final daily = svc.dailyAggregates(7);
      gen = daily.reversed.map((e) => e.solarGeneration).toList();
      cons = daily.reversed.map((e) => e.consumption).toList();
      imp = daily.reversed.map((e) => e.gridImport).toList();
    } else {
      // Average week-based series for month/year demo.
      final daily = svc.dailyAggregates(30);
      gen = List.generate(10, (i) {
        double s = 0;
        for (int j = 0; j < 3; j++) {
          s += daily[i * 3 + j].solarGeneration;
        }
        return s;
      });
      cons = List.generate(10, (i) {
        double s = 0;
        for (int j = 0; j < 3; j++) {
          s += daily[i * 3 + j].consumption;
        }
        return s;
      });
      imp = List.generate(10, (i) {
        double s = 0;
        for (int j = 0; j < 3; j++) {
          s += daily[i * 3 + j].gridImport;
        }
        return s;
      });
    }

    final totalCons = cons.fold<double>(0, (a, b) => a + b);
    final totalGen = gen.fold<double>(0, (a, b) => a + b);
    final totalImp = imp.fold<double>(0, (a, b) => a + b);
    final exportVal = isProducer ? svc.dailyAggregates(7).fold<double>(0, (a, r) => a + r.gridExport) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Section_banner(
            title: AppLocale.t('usageCosts'),
            subtitle: AppLocale.t('rateNote'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TimeRangeChips(
                  options: [
                    AppLocale.t('hourly'),
                    AppLocale.t('daily'),
                    AppLocale.t('monthly'),
                    AppLocale.t('yearly'),
                  ],
                  selected: _range,
                  onChanged: (i) => setState(() => _range = i),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE6EDE9)),
                  ),
                  child: Column(
                    children: [
                      // legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendDot(AppColors.teal500, AppLocale.t('consumption')),
                          const SizedBox(width: 14),
                          _legendDot(AppColors.amber500, AppLocale.t('imported')),
                          if (isProducer) ...[
                            const SizedBox(width: 14),
                            _legendDot(AppColors.teal100, AppLocale.t('exported')),
                          ],
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => setState(() => _showExport = !_showExport),
                            child: Row(children: [
                              Icon(
                                _showExport ? Icons.toggle_on : Icons.toggle_off,
                                color: AppColors.teal700,
                              ),
                              Text('grid', style: const TextStyle(fontSize: 11)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
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
                                  interval: (cons.length / 8).toDouble(),
                                  getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                                      style: const TextStyle(fontSize: 9, color: AppColors.inkSoft)),
                                ),
                              ),
                            ),
                            barGroups: List.generate(cons.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: cons[i],
                                    width: 7,
                                    borderRadius: BorderRadius.circular(3),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.teal500, AppColors.teal700],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  if (_showExport)
                                    BarChartRodData(
                                      toY: imp[i],
                                      width: 7,
                                      borderRadius: BorderRadius.circular(3),
                                      color: AppColors.amber500,
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // totals row (PowerPeers-style summary)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE6EDE9)),
                  ),
                  child: Column(
                    children: [
                      _row(AppLocale.t('consumption'),
                          '${totalCons.toStringAsFixed(1)} kWh'),
                      _row(AppLocale.t('imported'), '${totalImp.toStringAsFixed(1)} kWh'),
                      if (isProducer) ...[
                        _row(AppLocale.t('todayGeneration'), '${totalGen.toStringAsFixed(1)} kWh'),
                        _row(AppLocale.t('exported'), '${exportVal.toStringAsFixed(1)} kWh'),
                      ],
                      const Divider(height: 18),
                      _row(AppLocale.t('netConsumption'),
                          '${(totalImp).toStringAsFixed(1)} kWh', bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // cost estimate card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.teal50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: AppColors.teal700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocale.isBn
                              ? 'নিট ব্যবহার + সোলার-মিলান অংশের সেটেলমেন্ট = আনুমানিক মাসিক বিল ৳${(totalImp * 11).toStringAsFixed(0)}'
                              : 'Net usage + solar-matched settlement = est. monthly bill ৳${(totalImp * 11).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12.5, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) => Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
      ]);

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w400, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        ]),
      );
}
