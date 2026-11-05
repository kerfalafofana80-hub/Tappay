import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const TapPayApp());
}

// ============================================================
// APP
// ============================================================
class TapPayApp extends StatelessWidget {
  const TapPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// THEME
// ============================================================
class AppTheme {
  static const Color bg = Color(0xFF0B0F1A);
  static const Color card = Color(0xFF151B2B);
  static const Color accent = Color(0xFF4F8CFF);
  static const Color accent2 = Color(0xFF9B5CFF);
  static const Color textLight = Color(0xFFF5F7FF);
  static const Color textMuted = Color(0xFF8A93A6);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent2,
          surface: card,
        ),
        useMaterial3: true,
      );
}

// ============================================================
// MODEL
// ============================================================
class Payment {
  final double amount;
  final String merchant;
  final DateTime date;

  Payment({required this.amount, required this.merchant, required this.date});

  String get formattedAmount => '${amount.toStringAsFixed(2)} €';
}

// ============================================================
// HOME SCREEN
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _amount = 24.90;
  final String _merchant = 'Café Lumière';

  void _startPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TapScreen(amount: _amount, merchant: _merchant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('TapPay',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight)),
              const SizedBox(height: 8),
              const Text('Paiement simple et rapide',
                  style: TextStyle(color: AppTheme.textMuted)),
              const Spacer(),
              _card(),
              const Spacer(),
              _payButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accent, AppTheme.accent2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Montant à payer',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Text('${_amount.toStringAsFixed(2)} €',
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(_merchant,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [10, 20, 50].map((add) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: OutlinedButton(
                  onPressed: () => setState(() => _amount += add),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: Text('+$add'),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _payButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text('Payer maintenant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ============================================================
// TAP SCREEN (capteur simulé)
// ============================================================
class TapScreen extends StatefulWidget {
  final double amount;
  final String merchant;
  const TapScreen({super.key, required this.amount, required this.merchant});

  @override
  State<TapScreen> createState() => _TapScreenState();
}

class _TapScreenState extends State<TapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AuthScreen(amount: widget.amount, merchant: widget.merchant),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Approchez votre téléphone',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight)),
            const SizedBox(height: 8),
            const Text('du capteur de paiement',
                style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 60),
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ...List.generate(3, (i) {
                        final progress = (_controller.value + i / 3) % 1.0;
                        return Container(
                          width: 60 + progress * 160,
                          height: 60 + progress * 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppTheme.accent.withOpacity(1 - progress),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.accent, AppTheme.accent2],
                          ),
                        ),
                        child: const Icon(Icons.contactless,
                            color: Colors.white, size: 48),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Text('${widget.amount.toStringAsFixed(2)} € · ${widget.merchant}',
                style: const TextStyle(
                    color: AppTheme.textLight, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AUTH SCREEN (biométrie simulée)
// ============================================================
class AuthScreen extends StatefulWidget {
  final double amount;
  final String merchant;
  const AuthScreen({super.key, required this.amount, required this.merchant});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _scanning = false;
  Timer? _timer;

  void _authenticate() {
    setState(() => _scanning = true);
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SuccessScreen(amount: widget.amount, merchant: widget.merchant),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Authentification',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight)),
            const SizedBox(height: 8),
            const Text('Confirmez avec votre empreinte',
                style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _scanning ? null : _authenticate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _scanning ? AppTheme.accent : AppTheme.card,
                  border: Border.all(
                      color: AppTheme.accent.withOpacity(0.5), width: 2),
                ),
                child: Icon(
                  _scanning ? Icons.check_circle : Icons.fingerprint,
                  size: 72,
                  color: _scanning ? Colors.white : AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _scanning ? 'Vérification...' : 'Touchez pour simuler',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUCCESS SCREEN (reçu)
// ============================================================
class SuccessScreen extends StatelessWidget {
  final double amount;
  final String merchant;
  const SuccessScreen(
      {super.key, required this.amount, required this.merchant});

  @override
  Widget build(BuildContext context) {
    final payment =
        Payment(amount: amount, merchant: merchant, date: DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accent2]),
                ),
                child:
                    const Icon(Icons.check, color: Colors.white, size: 72),
              ),
              const SizedBox(height: 32),
              const Text('Paiement réussi !',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight)),
              const SizedBox(height: 8),
              Text(payment.formattedAmount,
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent)),
              const SizedBox(height: 4),
              Text(merchant, style: const TextStyle(color: AppTheme.textMuted)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    foregroundColor: AppTheme.textLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Nouveau paiement'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
