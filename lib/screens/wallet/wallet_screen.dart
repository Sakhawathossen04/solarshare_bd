import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/energy_service.dart';
import '../../core/services/session.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';

class WalletScreen extends StatefulWidget {
  final AppSession session;
  const WalletScreen({super.key, required this.session});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _kwh = 550;
  double _consumerRate = 11;
  double _producerRate = 9;
  double _other = 1;

  @override
  Widget build(BuildContext context) {
    final svc = EnergyService(widget.session);
    final isProducer = widget.session.isProducer;
    final settlement = svc.settlement(
      _kwh,
      consumerRate: _consumerRate,
      producerRate: _producerRate,
      other: _other,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Section_banner(
            title: AppLocale.t('wallet'),
            subtitle: AppLocale.t('settlementCalc'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // balance card
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocale.t('walletBalance'),
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '৳ ${widget.session.walletBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // settlement calculator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE6EDE9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.calculate_outlined, color: AppColors.teal700),
                        const SizedBox(width: 8),
                        Text(AppLocale.t('settlementCalc'),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ]),
                      const SizedBox(height: 14),
                      _numField(AppLocale.t('settledEnergy'), _kwh, (v) => setState(() => _kwh = v)),
                      const SizedBox(height: 10),
                      _numField(AppLocale.t('consumerCharge'), _consumerRate,
                          (v) => setState(() => _consumerRate = v)),
                      const SizedBox(height: 10),
                      _numField(AppLocale.t('producerPayout'), _producerRate,
                          (v) => setState(() => _producerRate = v)),
                      const SizedBox(height: 10),
                      _numField(AppLocale.t('otherCosts'), _other, (v) => setState(() => _other = v)),
                      const SizedBox(height: 16),
                      _line(AppLocale.t('consumerCollection'),
                          '৳ ${settlement.consumerCollection.toStringAsFixed(2)}'),
                      _line(AppLocale.t('producerPayment'),
                          '৳ ${settlement.producerPayment.toStringAsFixed(2)}'),
                      _line(AppLocale.t('otherCosts'),
                          '৳ ${settlement.otherCosts.toStringAsFixed(2)}'),
                      const Divider(height: 20),
                      _line(AppLocale.t('remainingAmount'),
                          '৳ ${settlement.remaining.toStringAsFixed(2)}',
                          bold: true),
                      const SizedBox(height: 10),
                      Text(
                        AppLocale.isBn
                            ? 'বাকি পরিমাণ positive হলেই সেটি platform-এর profit নয় — utility cost, taxes, losses ও balancing charges ধরতে হবে।'
                            : 'A positive remaining amount is NOT platform profit — utility cost, taxes, losses and balancing charges must still be covered.',
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(AppLocale.t('paymentHistory'), icon: Icons.history),
                const SizedBox(height: 10),
                ...svc.txns().map(_txnTile),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(String label, double value, ValueChanged<double> onChanged) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      controller: TextEditingController(text: value.toString()),
      onChanged: (s) {
        final v = double.tryParse(s);
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: bold ? AppColors.teal700 : AppColors.ink)),
        ]),
      );

  Widget _txnTile(dynamic txn) {
    final isCredit = txn.type.name == 'credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isCredit ? AppColors.teal100 : AppColors.amber100,
          child: Icon(
            isCredit ? Icons.south_west : Icons.north_east,
            size: 16,
            color: isCredit ? AppColors.teal700 : AppColors.orange500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(txn.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${txn.date.day}/${txn.date.month}/${txn.date.year}',
                  style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
            ],
          ),
        ),
        Text(
          '${isCredit ? '+' : '-'}৳${txn.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: isCredit ? AppColors.teal700 : AppColors.orange500,
          ),
        ),
      ]),
    );
  }
}
