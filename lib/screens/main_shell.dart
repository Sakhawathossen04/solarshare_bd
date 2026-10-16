import 'package:flutter/material.dart';
import '../core/l10n/app_locale.dart';
import '../core/services/session.dart';
import 'home/home_screen.dart';
import 'market/market_screen.dart';
import 'wallet/wallet_screen.dart';
import 'insights/insights_screen.dart';
import 'settings/settings_screen.dart';
import 'admin/admin_screen.dart';

class MainShell extends StatefulWidget {
  final AppSession session;
  const MainShell({super.key, required this.session});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.session.isAdmin;
    final tabs = [
      HomeScreen(session: widget.session),
      MarketScreen(session: widget.session),
      InsightsScreen(session: widget.session),
      WalletScreen(session: widget.session),
      SettingsScreen(session: widget.session),
    ];
    if (isAdmin) {
      tabs[1] = const AdminScreen();
    }

    final labels = [
      AppLocale.t('home'),
      isAdmin ? AppLocale.t('adminDashboard') : AppLocale.t('market'),
      AppLocale.t('insights'),
      AppLocale.t('wallet'),
      AppLocale.t('settings'),
    ];
    final icons = const [
      Icons.home_outlined,
      isAdmin ? Icons.admin_panel_settings_outlined : Icons.storefront_outlined,
      Icons.insights_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.settings_outlined,
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: List.generate(
          5,
          (i) => NavigationDestination(
            icon: Icon(icons[i]),
            selectedIcon: Icon(icons[i], color: Theme.of(context).colorScheme.primary),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}
