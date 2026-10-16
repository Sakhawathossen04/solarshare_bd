import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/session.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppSession session;
  const SettingsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        children: [
          // profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6EDE9)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.teal100,
                  child: Text(
                    session.user!.name.characters.first,
                    style: const TextStyle(
                        color: AppColors.teal900,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.user!.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.teal900)),
                      Text('${session.user!.email} · ${session.user!.meterId}',
                          style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _group(AppLocale.t('myEnergy'), [
            _item(Icons.receipt_long_outlined, AppLocale.t('meterDetails'), '${session.user!.meterId}'),
            _item(Icons.history, AppLocale.t('energyHistory'), session.user!.area),
            _item(Icons.verified_outlined, AppLocale.t('meterValidation'), 'OK'),
          ]),
          const SizedBox(height: 18),
          _group(AppLocale.t('financial'), [
            _item(Icons.account_balance_wallet_outlined, AppLocale.t('walletBalance'),
                '৳ ${session.walletBalance.toStringAsFixed(2)}'),
            _item(Icons.receipt, AppLocale.t('monthlyStatement'), ''),
            _item(Icons.credit_card_outlined, 'Payment methods', ''),
          ]),
          const SizedBox(height: 18),
          _group(AppLocale.t('myData'), [
            _item(Icons.person_outline, AppLocale.t('personalInfo'), ''),
            _item(Icons.notifications_outlined, AppLocale.t('notificationPref'), ''),
            _item(Icons.language, AppLocale.t('language'), ''),
          ]),
          const SizedBox(height: 18),
          // language switcher
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6EDE9)),
            ),
            child: ValueListenableBuilder<String>(
              valueListenable: AppLocale.current,
              builder: (_, v, __) => Column(
                children: [
                  RadioListTile<String>(
                    value: 'bn',
                    groupValue: v,
                    onChanged: (_) => AppLocale.set('bn'),
                    title: const Text('বাংলা', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: v,
                    onChanged: (_) => AppLocale.set('en'),
                    title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          // about
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.teal50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${AppLocale.t('aboutApp')} — ${AppLocale.t('projectNote')}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft, height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(AppLocale.t('logout')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal900)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6EDE9)),
            ),
            child: Column(
              children: List.generate(items.length, (i) => [
                items[i],
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 52),
              ]).expand((e) => e).toList(),
            ),
          ),
        ],
      );

  Widget _item(IconData icon, String title, String sub) => ListTile(
        leading: Icon(icon, color: AppColors.teal700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: sub.isEmpty ? null : Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.inkSoft),
        onTap: () {},
      );
}
