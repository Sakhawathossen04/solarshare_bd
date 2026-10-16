import 'package:flutter/material.dart';
import '../core/l10n/app_locale.dart';
import '../core/theme/app_theme.dart';

/// Mint info banner like PowerPeers hero sections.
class Section_banner extends StatelessWidget {
  final String title;
  final String subtitle;
  const Section_banner({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.teal50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.teal900)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? accent;
  final IconData? icon;

  const StatTile({super.key, required this.label, required this.value, this.sub, this.accent, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EDE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: accent ?? AppColors.teal700),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
            ),
          ]),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink, fontFamily: 'HindSiliguri'),
              children: [
                TextSpan(text: value),
                if (sub != null)
                  TextSpan(
                    text: '  $sub',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400, color: AppColors.orange500),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  const SectionTitle(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: AppColors.teal700),
        const SizedBox(width: 6),
      ],
      Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.teal900)),
    ]);
  }
}

class SimBadge extends StatelessWidget {
  const SimBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'SIMULATED',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: Color(0xFF9A6B18)),
      ),
    );
  }
}

class TimeRangeChips extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const TimeRangeChips({super.key, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.teal50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.teal700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

String bnNum(String s) => s; // digits kept Latin for clarity in both languages
