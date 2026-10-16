import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/sim_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = seedAlerts();
    final stats = seedAreaStats();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(color: AppColors.teal50),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_outlined, color: AppColors.teal900),
                const SizedBox(width: 8),
                Text(
                  AppLocale.t('adminDashboard'),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.teal900),
                ),
                const Spacer(),
                const SimBadge(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // summary tiles
                Row(
                  children: [
                    Expanded(child: StatTile(label: AppLocale.t('producers'), value: '12', icon: Icons.wb_sunny_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: StatTile(label: AppLocale.t('consumers'), value: '28', icon: Icons.group_outlined)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: StatTile(label: AppLocale.t('meterValidation'), value: '40/40', sub: 'OK', icon: Icons.verified_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: StatTile(label: AppLocale.t('settle'), value: '৳ 8,470', icon: Icons.account_balance_outlined)),
                  ],
                ),
                const SizedBox(height: 20),
                SectionTitle(AppLocale.t('areaStats'), icon: Icons.map_outlined),
                const SizedBox(height: 10),
                ...stats.map((s) => _AreaCard(s)),
                const SizedBox(height: 20),
                SectionTitle(AppLocale.t('systemAlerts'), icon: Icons.notifications_active_outlined),
                const SizedBox(height: 10),
                ...alerts.map((a) => _AlertCard(a)),
                const SizedBox(height: 20),
                SectionTitle(AppLocale.t('auditLog'), icon: Icons.receipt_outlined),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE6EDE9)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AuditLine('12:04  P-001 interval 12:00 accepted (signed)'),
                      _AuditLine('12:04  P-001 duplicate reading rejected'),
                      _AuditLine('09:11  C-102 tariff update applied by admin'),
                      _AuditLine('08:40  Settlement batch #221 reconciled ✓'),
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
}

class _AreaCard extends StatelessWidget {
  final AreaStat s;
  const _AreaCard(this.s);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.teal700),
            const SizedBox(width: 6),
            Expanded(child: Text(s.area, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
            Text('${(s.matchRatio * 100).toStringAsFixed(0)}% ${AppLocale.t('matchRatio')}',
                style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: s.matchRatio,
                  minHeight: 8,
                  backgroundColor: AppColors.teal100,
                  valueColor: const AlwaysStoppedAnimation(AppColors.teal500),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            '${AppLocale.t('todayGeneration')}: ${s.generatedKwh} kWh · ${AppLocale.t('consumption')}: ${s.consumedKwh} kWh',
            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final SystemAlert a;
  const _AlertCard(this.a);

  Color get _color {
    switch (a.level) {
      case AlertLevel.critical:
        return AppColors.danger;
      case AlertLevel.warning:
        return AppColors.orange500;
      default:
        return AppColors.teal500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 10, color: _color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                Text(a.detail, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.45)),
              ],
            ),
          ),
          Text('${a.time.hour}:${a.time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

class _AuditLine extends StatelessWidget {
  final String text;
  const _AuditLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: AppColors.ink)),
    );
  }
}
