import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:an_open_soul_app/services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedIndex = 0;
  List<ProductDetails> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await SubscriptionService().init();
    setState(() {
      _availableProducts = SubscriptionService().products;
    });
  }

  Future<void> _handlePlanSelection(Map<String, dynamic> plan, int index) async {
    final selectedPlanName = plan['name'] as String;
    setState(() => selectedIndex = index);

    if (index > 0 && _availableProducts.isNotEmpty) {
      final product = _availableProducts.firstWhere(
        (p) => p.id == plan['id'],
        orElse: () => throw Exception('Product not found'),
      );
      await SubscriptionService().buy(product);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Subscription Activated!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You’ve successfully selected the $selectedPlanName plan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final plans = [
      {
        'name': 'Echo',
        'icon': '🌒',
        'description': '• You can talk to Nova\n• Messages are not saved\n• Daily limit applies',
        'model': 'GPT-3.5',
        'price': 'Free',
        'highlight': false,
        'popular': false,
      },
      {
        'name': 'Pulse',
        'icon': '🩶',
        'description': '• Chat history saved\n• More messages per day\n• Avatar glow unlocked',
        'model': 'GPT-3.5+',
        'price': '\$4.99 / month',
        'highlight': false,
        'popular': false,
        'id': 'plan_pulse'
      },
      {
        'name': 'NovaLink',
        'icon': '🔮',
        'description': '• Unlimited depth\n• Voice interaction\n• Priority Nova sync',
        'model': 'GPT-4o 🚀',
        'price': '\$9.99 / month',
        'highlight': true,
        'popular': true,
        'id': 'plan_novalink'
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Choose Your Plan',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [if (isDark) const Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final plan = plans[index];
          final isHighlighted = plan['highlight'] as bool;
          final isPopular = plan['popular'] as bool;
          final isSelected = selectedIndex == index;

          double scale = 1.0;

          return StatefulBuilder(
            builder: (context, setStateInner) {
              return GestureDetector(
                onTapDown: (_) => setStateInner(() => scale = 0.97),
                onTapUp: (_) => setStateInner(() => scale = 1.0),
                onTapCancel: () => setStateInner(() => scale = 1.0),
                child: Stack(
                  children: [
                    AnimatedScale(
                      scale: scale,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isHighlighted
                              ? const LinearGradient(
                                  colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isHighlighted
                              ? null
                              : isDark
                                  ? Colors.white.withAlpha((0.05 * 255).toInt())
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 2,
                            color: isSelected
                                ? Colors.lightGreenAccent.withAlpha((0.8 * 255).toInt())
                                : Colors.transparent,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.1 * 255).toInt()),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: isDark
                                ? ImageFilter.blur(sigmaX: 6, sigmaY: 6)
                                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${plan['icon']} ${plan['name']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Your Plan',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.withAlpha((0.1 * 255).toInt()),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            plan['model'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.deepPurpleAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isPopular)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Most Popular',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  plan['description'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      plan['price'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    isSelected
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: Text(
                                              'Current Plan',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isHighlighted ? Colors.deepPurpleAccent : Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                            ),
                                            onPressed: () => _handlePlanSelection(plan, index),
                                            child: Text(
                                              isHighlighted ? "Subscribe" : "Select",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}