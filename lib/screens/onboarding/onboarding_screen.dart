import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  static const List<Map<String, String>> _slides = [
    {
      'emoji': '☀️',
      'title_bn': 'আপনার সোলার, আপনার আয়',
      'title_en': 'Your solar, your income',
      'body_bn':
          'রুফটপ সোলারের অতিরিক্ত বিদ্যুৎ স্মার্ট মিটার দিয়ে মেপে কমিউনিটিতে শেয়ার করুন আর আয় করুন।',
      'body_en':
          'Measure your rooftop solar surplus with smart meters and share it with your community to earn.',
    },
    {
      'emoji': '🤝',
      'title_bn': 'প্রতিবেশীর সাথে এনার্জি শেয়ার',
      'title_en': 'Share energy with neighbours',
      'body_bn':
          'মার্কেটপ্লেসে অতিরিক্ত বিদ্যুৎ অফার করুন — একই এলাকার গ্রাহক তা কিনতে পারবেন, সেটেলমেন্ট স্বচ্ছ হবে।',
      'body_en':
          'Offer surplus on the marketplace — consumers in your area buy it, with transparent settlement.',
    },
    {
      'emoji': '📊',
      'title_bn': 'স্বচ্ছ বিলিং ও পূর্বাভাস',
      'title_en': 'Transparent billing & forecast',
      'body_bn':
          'ঘণ্টা, দিন, মাস ভিত্তিক ব্যবহার-খরচ দেখুন, আর AI দিয়ে ৭ দিনের সোলার পূর্বাভাস পান।',
      'body_en':
          'See hourly/daily/monthly usage-costs and get 7-day AI solar forecasts.',
    },
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _slides[_page];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Language switcher
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  ValueListenableBuilder<String>(
                    valueListenable: AppLocale.current,
                    builder: (_, v, __) => SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'bn', label: Text('বাংলা')),
                        ButtonSegment(value: 'en', label: Text('English')),
                      ],
                      selected: {v},
                      onSelectionChanged: (_) => AppLocale.toggle(),
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        foregroundColor: AppColors.teal900,
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: AppColors.teal700,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal700 : AppColors.teal100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _page < _slides.length - 1
                      ? context.t('next')
                      : context.t('getStarted'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final Map<String, String> slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final bn = AppLocale.isBn;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.teal100, AppColors.amber100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(slide['emoji']!, style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            bn ? slide['title_bn']! : slide['title_en']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: AppColors.teal900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bn ? slide['body_bn']! : slide['body_en']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
