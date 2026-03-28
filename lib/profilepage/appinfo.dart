import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const brownDark = Color(0xFF4E342E);
    const brownSoft = Color(0xFF6D4C41);
    const greenDark = Color(0xFF2E7D32);
    const greenSoft = Color(0xFF66BB6A);
    const cream = Color(0xFFF8F5E9);

    return Scaffold(
      body: Stack(
        children: [
          /// Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backg.png',
              fit: BoxFit.cover,
            ),
          ),

          /// Dark overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    brownDark.withOpacity(0.78),
                    greenDark.withOpacity(0.72),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'App Info',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cream.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: brownSoft.withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// Top logo
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: greenDark.withOpacity(0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Image(
                                image: AssetImage('assets/cict.png'),
                                height: 70,
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// Main app logo
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [greenSoft, greenDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: greenDark.withOpacity(0.28),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/u.png',
                                height: 110,
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'PesCoa',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: brownDark,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: greenDark.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Smart Cocoa Pest Monitoring',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: greenDark,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'PesCoa provides smart and reliable support for cocoa pest monitoring and management. '
                              'It helps users identify pest-related concerns and promotes more efficient, eco-friendly, '
                              'and informed agricultural practices. With a focus on usability and accuracy, PesCoa is '
                              'designed to support farmers, researchers, and communities in maintaining healthier cocoa production.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.5,
                                height: 1.6,
                                color: Color(0xFF4A3B35),
                              ),
                            ),

                            const SizedBox(height: 28),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _infoChip(
                                  icon: Icons.eco,
                                  label: 'Eco-Friendly',
                                  color: greenDark,
                                ),
                                const SizedBox(width: 10),
                                _infoChip(
                                  icon: Icons.shield_outlined,
                                  label: 'Reliable',
                                  color: brownSoft,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    brownSoft.withOpacity(0.12),
                                    greenDark.withOpacity(0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: brownDark, size: 18),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Developed to make pest monitoring more accessible and visually engaging.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: brownDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
