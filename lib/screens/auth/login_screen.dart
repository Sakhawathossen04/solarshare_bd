import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/services/session.dart';
import '../../core/theme/app_theme.dart';
import '../main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'rafik@demo.bd');
  final _password = TextEditingController(text: 'demo1234');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _loginAs(AppUser user) {
    final session = AppSession();
    session.user = user;
    session.walletBalance =
        user.role == UserRole.producer ? 1450.0 : -320.0;
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const _Logo(size: 84),
                const SizedBox(height: 12),
                Text(
                  AppLocale.t('appName'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.teal900,
                  ),
                ),
                Text(
                  AppLocale.t('tagline'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: AppLocale.t('email'),
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocale.t('password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _loginAs(AppSession.demoProducer),
                  child: Text(AppLocale.t('login')),
                ),
                const SizedBox(height: 28),
                Text(
                  AppLocale.t('demoNotice'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal100,
                        foregroundColor: AppColors.teal900,
                      ),
                      onPressed: () => _loginAs(AppSession.demoProducer),
                      child: Text(AppLocale.t('producer')),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.amber100,
                        foregroundColor: AppColors.ink,
                      ),
                      onPressed: () => _loginAs(AppSession.demoConsumer),
                      child: Text(AppLocale.t('consumer')),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE3E7EA),
                        foregroundColor: AppColors.ink,
                      ),
                      onPressed: () => _loginAs(AppSession.demoAdmin),
                      child: Text('Admin'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline logo widget drawn with shapes (no image asset needed).
class _Logo extends StatelessWidget {
  final double size;
  const _Logo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    // sun
    final sun = Paint()..color = AppColors.amber500;
    canvas.drawCircle(c, r * 0.42, sun);
    // rays
    final ray = Paint()
      ..color = AppColors.amber500
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4 - pi / 2;
      final from = c + Offset(cos(a), sin(a)) * r * 0.6;
      final to = c + Offset(cos(a), sin(a)) * r * 0.82;
      canvas.drawLine(from, to, ray);
    }
    // leaf/share arc
    final arc = Paint()
      ..color = AppColors.teal700
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.95),
      pi * 0.15,
      pi * 1.2,
      false,
      arc,
    );
    // arc endpoint dot
    final tip = c + Offset(cos(pi * 1.35), sin(pi * 1.35)) * r * 0.95;
    canvas.drawCircle(tip, size.width * 0.045, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
