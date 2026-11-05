import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const TapPayApp());

class TapPayApp extends StatelessWidget {
  const TapPayApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TapPay',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0F1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4F8CFF),
            secondary: Color(0xFF9B5CFF),
            surface: Color(0xFF151B2B),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      );
}

class Payment {
  const Payment({required this.amount, required this.merchant, required this.date});
  final double amount;
  final String merchant;
  final DateTime date;

  String get formattedAmount => '${amount.toStringAsFixed(2).replaceAll('.', ',')} €';
  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double amount = 24.90;
  final String merchant = 'Café Lumière';
  final List<Payment> payments = [];

  void startPayment() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TapScreen(
        amount: amount,
        merchant: merchant,
        onPaid: (payment) => setState(() => payments.insert(0, payment)),
      ),
    ));
  }

  void openHistory() => Navigator.push(context, MaterialPageRoute(
        builder: (_) => HistoryScreen(payments: payments),
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(children: [
                const Icon(Icons.contactless, color: Color(0xFF4F8CFF), size: 36),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TapPay', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Text('Paiement simple et rapide', style: TextStyle(color: Color(0xFF8A93A6))),
                ])),
                IconButton(onPressed: openHistory, tooltip: 'Historique', icon: const Icon(Icons.receipt_long)),
              ]),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4F8CFF), Color(0xFF9B5CFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('MONTANT À PAYER', style: TextStyle(color: Colors.white70, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('${amount.toStringAsFixed(2).replaceAll('.', ',')} €', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(merchant, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 18),
                  Wrap(spacing: 8, children: [10, 20, 50].map((add) => ActionChip(
                    label: Text('+$add €'),
                    onPressed: () => setState(() => amount += add),
                    backgroundColor: Colors.white24,
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList()),
                ]),
              ),
              const SizedBox(height: 12),
              const Text('Démo uniquement : aucun paiement réel n’est effectué.', style: TextStyle(color: Color(0xFF8A93A6), fontSize: 12)),
              const SizedBox(height: 22),
              SizedBox(height: 56, child: FilledButton.icon(
                onPressed: startPayment,
                icon: const Icon(Icons.contactless),
                label: const Text('Payer maintenant', style: TextStyle(fontSize: 17)),
              )),
              const SizedBox(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Derniers paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: openHistory, child: const Text('Tout voir')),
              ]),
              if (payments.isEmpty)
                const Card(child: ListTile(leading: Icon(Icons.history), title: Text('Aucun paiement pour le moment')))
              else
                ...payments.take(3).map((payment) => PaymentTile(payment: payment)),
            ],
          ),
        ),
      );
}

class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key, required this.payment});
  final Payment payment;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
          title: Text(payment.merchant),
          subtitle: Text(payment.formattedDate),
          trailing: Text(payment.formattedAmount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.payments});
  final List<Payment> payments;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Historique')),
        body: payments.isEmpty
            ? const Center(child: Text('Aucun paiement pour le moment'))
            : ListView(padding: const EdgeInsets.all(16), children: payments.map((p) => PaymentTile(payment: p)).toList()),
      );
}

class TapScreen extends StatefulWidget {
  const TapScreen({super.key, required this.amount, required this.merchant, required this.onPaid});
  final double amount;
  final String merchant;
  final ValueChanged<Payment> onPaid;
  @override
  State<TapScreen> createState() => _TapScreenState();
}

class _TapScreenState extends State<TapScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthScreen(
        amount: widget.amount, merchant: widget.merchant, onPaid: widget.onPaid,
      )));
    });
  }
  @override
  void dispose() { timer?.cancel(); controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Paiement sans contact')),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Approchez votre téléphone', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('du capteur de paiement', style: TextStyle(color: Color(0xFF8A93A6))),
          const SizedBox(height: 40),
          SizedBox(width: 220, height: 220, child: AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Stack(alignment: Alignment.center, children: [
              ...List.generate(3, (i) {
                final progress = (controller.value + i / 3) % 1.0;
                return Container(width: 60 + progress * 160, height: 60 + progress * 160,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4F8CFF).withValues(alpha: 1 - progress), width: 2)));
              }),
              const CircleAvatar(radius: 45, backgroundColor: Color(0xFF4F8CFF), child: Icon(Icons.contactless, size: 48, color: Colors.white)),
            ]),
          )),
          const SizedBox(height: 30),
          Text('${widget.amount.toStringAsFixed(2)} € · ${widget.merchant}'),
          const SizedBox(height: 12),
          const Text('Simulation uniquement', style: TextStyle(color: Color(0xFF8A93A6), fontSize: 12)),
        ])),
      );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.amount, required this.merchant, required this.onPaid});
  final double amount;
  final String merchant;
  final ValueChanged<Payment> onPaid;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool scanning = false;
  Timer? timer;
  void authenticate() {
    if (scanning) return;
    setState(() => scanning = true);
    timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final payment = Payment(amount: widget.amount, merchant: widget.merchant, date: DateTime.now());
      widget.onPaid(payment);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SuccessScreen(payment: payment)));
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Confirmation')),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Authentification', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Confirmez pour continuer', style: TextStyle(color: Color(0xFF8A93A6))),
          const SizedBox(height: 36),
          Semantics(button: true, label: 'Simuler une authentification', child: GestureDetector(
            onTap: scanning ? null : authenticate,
            child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 140, height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle, color: scanning ? const Color(0xFF4F8CFF) : const Color(0xFF151B2B), border: Border.all(color: const Color(0xFF4F8CFF), width: 2)),
              child: Icon(scanning ? Icons.check_circle : Icons.fingerprint, size: 72, color: Colors.white)),
          )),
          const SizedBox(height: 24),
          Text(scanning ? 'Vérification...' : 'Touchez pour simuler', style: const TextStyle(color: Color(0xFF8A93A6))),
          const SizedBox(height: 12),
          const Text('Aucune donnée biométrique n’est utilisée.', style: TextStyle(color: Color(0xFF8A93A6), fontSize: 12)),
        ])),
      );
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.payment});
  final Payment payment;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const Spacer(),
          const CircleAvatar(radius: 56, backgroundColor: Color(0xFF4F8CFF), child: Icon(Icons.check, size: 68, color: Colors.white)),
          const SizedBox(height: 28),
          const Text('Simulation terminée', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(payment.formattedAmount, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4F8CFF))),
          const SizedBox(height: 6),
          Text(payment.merchant, style: const TextStyle(color: Color(0xFF8A93A6))),
          const SizedBox(height: 20),
          Text(payment.formattedDate, style: const TextStyle(color: Color(0xFF8A93A6))),
          const SizedBox(height: 14),
          const Text('Ceci est une démonstration. Aucun débit bancaire n’a eu lieu.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8A93A6), fontSize: 12)),
          const Spacer(),
          SizedBox(width: double.infinity, height: 54, child: FilledButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Retour à l’accueil'),
          )),
          const SizedBox(height: 12),
        ]))),
      );
}
