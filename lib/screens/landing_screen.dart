import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Warm Editorial Cream & Forest Emerald Theme Palette
    final bg = isDark ? const Color(0xFF101211) : const Color(0xFFF7F4EE);
    final surfaceLight = const Color(0xFFFAF7F0);
    final surfaceDark = const Color(0xFF181B19);
    final cardBg = isDark ? surfaceDark : surfaceLight;

    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);
    final emeraldButton = isDark ? const Color(0xFF2D4D36) : const Color(0xFF172C1E);

    final borderLight = const Color(0x38DFCDBC);
    final borderDark = Colors.white.withValues(alpha: 0.12);
    final borderColor = isDark ? borderDark : borderLight;

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : const Color(0xFF735C4A).withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // 1. Sleek Floating Top Navigation Bar
                  _buildTopBar(
                    context,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    shadowColor: shadowColor,
                    textPrimary: textPrimary,
                    emeraldAccent: emeraldAccent,
                  ),

                  const SizedBox(height: 12),

                  // 2. Large Vertical Hero Image (Covers majority of vertical space)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Vertical Editorial Hero Image
                            Image.asset(
                              'assets/images/pocketllm_hero_art.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/images/cozy_study_ai.png',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Smooth cinematic bottom gradient for text contrast
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 140,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Floating Glass Card with Application Name & Tagline
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: GlassContainer(
                                blur: 16,
                                opacity: 0.72,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                borderRadius: BorderRadius.circular(22),
                                color: Colors.black.withValues(alpha: 0.42),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  width: 1.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'PocketLLM',
                                            style: TextStyle(
                                              color: Color(0xFFF7F4EE),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              fontFamily: 'serif',
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'INTELLIGENCE MEETS ELEGANCE',
                                            style: TextStyle(
                                              color: Color(0xFFA6D4B0),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF172C1E).withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFA6D4B0).withValues(alpha: 0.4),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock_outline_rounded,
                                            size: 11,
                                            color: Color(0xFFA6D4B0),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '100% Local',
                                            style: TextStyle(
                                              color: Color(0xFFF7F4EE),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Primary Call to Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldButton,
                        foregroundColor: const Color(0xFFF7F4EE),
                        elevation: 5,
                        shadowColor: emeraldButton.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 0.9,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/chat');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFFF7F4EE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Top Navigation Bar ---
  Widget _buildTopBar(
    BuildContext context, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color shadowColor,
    required Color textPrimary,
    required Color emeraldAccent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: isDark ? 0.92 : 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF3F6649).withValues(alpha: 0.28)
                      : const Color(0xFF172C1E).withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: emeraldAccent,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'PocketLLM',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'serif',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262A27)
                      : const Color(0xFFEDE8DC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0x35DFCDBC),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      'v2.0 Private',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF8BB596) : const Color(0xFF14261A),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Theme Toggle Button with comfortable mobile touch target
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeController,
            builder: (context, mode, child) {
              return Tooltip(
                message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                child: InkWell(
                  onTap: () => themeController.toggleTheme(),
                  borderRadius: BorderRadius.circular(22),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(7.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFEDE8DC),
                          border: Border.all(
                            color: borderColor,
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 15,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
