import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/energy_service.dart';
import '../../core/services/session.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class MarketScreen extends StatelessWidget {
  final AppSession session;
  const MarketScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final svc = EnergyService(session);
    final isProducer = session.isProducer;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Section_banner(
            title: AppLocale.t('marketplace'),
            subtitle: AppLocale.t(isProducer ? 'eligibleSurplus' : 'findSolar'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (isProducer) ...[
                  _ProducerOfferCard(svc: svc),
                  const SizedBox(height: 20),
                  SectionTitle(AppLocale.t('areaDemand'), icon: Icons.groups_outlined),
                  const SizedBox(height: 10),
                  _AreaDemandRow(area: 'ধানমন্ডি, ঢাকা', demandKwh: 18.5),
                  _AreaDemandRow(area: 'উত্তরা, ঢাকা', demandKwh: 12.0),
                  _AreaDemandRow(area: 'আগ্রাবাদ, চট্টগ্রাম', demandKwh: 9.4),
                  const SizedBox(height: 20),
                  SectionTitle(AppLocale.t('mySurplusListings'), icon: Icons.list_alt),
                  const SizedBox(height: 10),
                  ...svc.offers().map((o) => _OfferCard(offer: o, svc: svc)),
                ] else ...[
                  Text(AppLocale.t('nearbyProducers'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.teal900)),
                  const SizedBox(height: 10),
                  ...svc.community().map((m) => _ProducerCard(member: m, svc: svc)),
                  const SizedBox(height: 20),
                  Text(AppLocale.t('matchedEnergyQ'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.teal900)),
                  const SizedBox(height: 10),
                  _MatchCard(svc: svc),
                  const SizedBox(height: 20),
                  SectionTitle(AppLocale.t('billingHistory'), icon: Icons.receipt_long_outlined),
                  const SizedBox(height: 10),
                  ...svc.trades().map((tr) => _TradeCard(trade: tr)),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Producer: shows eligible surplus + a "list for sale" panel.
class _ProducerOfferCard extends StatefulWidget {
  final EnergyService svc;
  const _ProducerOfferCard({required this.svc});

  @override
  State<_ProducerOfferCard> createState() => _ProducerOfferCardState();
}

class _ProducerOfferCardState extends State<_ProducerOfferCard> {
  double _kwh = 4.0;

  @override
  Widget build(BuildContext context) {
    final surplus = widget.svc.todayExport();
    return Container(
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
            const Icon(Icons.bolt, color: AppColors.amber500),
            const SizedBox(width: 8),
            Expanded(child: Text(AppLocale.t('eligibleSurplus'),
                style: const TextStyle(fontWeight: FontWeight.w700))),
            Text('${surplus.toStringAsFixed(1)} kWh',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.teal700)),
          ]),
          const SizedBox(height: 14),
          Text('${AppLocale.t('amount')}: ${_kwh.toStringAsFixed(1)} kWh  ·  ${AppLocale.t('proposedRate')}: ৳9.0',
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
          Slider(
            value: _kwh,
            min: 0.5,
            max: surplus < 0.5 ? 0.5 : surplus,
            divisions: 20,
            activeColor: AppColors.teal700,
            label: '${_kwh.toStringAsFixed(1)} kWh',
            onChanged: (v) => setState(() => _kwh = v),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: Text(AppLocale.t('listForSale')),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${AppLocale.t('listForSale')}: ${_kwh.toStringAsFixed(1)} kWh @ ৳9.0 — ${AppLocale.t('status')}: ${AppLocale.t('pending')}'),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaDemandRow extends StatelessWidget {
  final String area;
  final double demandKwh;
  const _AreaDemandRow({required this.area, required this.demandKwh});

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
      child: Row(children: [
        const Icon(Icons.location_on_outlined, size: 18, color: AppColors.teal700),
        const SizedBox(width: 10),
        Expanded(child: Text(area, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Text('$demandKwh kWh ${AppLocale.t('byTime')}',
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
      ]),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final EnergyOffer offer;
  final EnergyService svc;
  const _OfferCard({required this.offer, required this.svc});

  @override
  Widget build(BuildContext context) {
    final settled = offer.status == OfferStatus.settled;
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
          backgroundColor: AppColors.teal100,
          child: Text(offer.producerName.characters.first,
              style: const TextStyle(color: AppColors.teal900, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(offer.producerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              Text('${offer.area} · ${offer.kwh} kWh @ ৳${offer.ratePerKwh}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: settled ? AppColors.teal100 : AppColors.amber100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            settled ? AppLocale.t('settled') : AppLocale.t('pending'),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: settled ? AppColors.teal700 : const Color(0xFF9A6B18),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Consumer: nearby producers with buy action.
class _ProducerCard extends StatelessWidget {
  final CommunityMember member;
  final EnergyService svc;
  const _ProducerCard({required this.member, required this.svc});

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
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: AppColors.amber100,
          child: Icon(Icons.wb_sunny_outlined, color: AppColors.orange500, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              Text('${member.area} · ${member.kwhToday} kWh ${AppLocale.t('today')} · ⭐ ${member.rating}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
            ],
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.teal700,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
          ),
          onPressed: () => _buyDialog(context),
          child: Text(AppLocale.t('buy'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  void _buyDialog(BuildContext context) {
    final settlement = svc.settlement(member.kwhToday / 2);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocale.t('settleNow')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${member.name} — ${(member.kwhToday / 2).toStringAsFixed(1)} kWh'),
            const SizedBox(height: 12),
            _settleLine(AppLocale.t('consumerCharge'), '৳${settlement.consumerRate}'),
            _settleLine(AppLocale.t('total'), '৳${settlement.consumerCollection.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(AppLocale.t('demoNotice'),
                style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocale.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${AppLocale.t('status')}: ${AppLocale.t('settled')} ✓'),
              ));
            },
            child: Text(AppLocale.t('ok')),
          ),
        ],
      ),
    );
  }

  Widget _settleLine(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _MatchCard extends StatelessWidget {
  final EnergyService svc;
  const _MatchCard({required this.svc});

  @override
  Widget build(BuildContext context) {
    final ratio = svc.matchRatio();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppLocale.t('matchRatio'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            Text('${(ratio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.teal700, fontSize: 16)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.teal100,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal500),
            ),
          ),
          const SizedBox(height: 8),
          Text(AppLocale.t('rateNote'),
              style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  final Trade trade;
  const _TradeCard({required this.trade});

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
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined, color: AppColors.teal700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${trade.kwh} kWh @ ৳${trade.ratePerKwh}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              Text(
                  '${trade.settledAt.day}/${trade.settledAt.month}/${trade.settledAt.year}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
            ],
          ),
        ),
        Text('৳${trade.total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.teal700)),
      ]),
    );
  }
}
