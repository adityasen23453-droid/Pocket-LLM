import 'dart:ui';
import 'package:flutter/material.dart';

/// High-performance ready-to-ship Glassmorphism Container with BackdropFilter blur,
/// translucent background, high-contrast borders, and drop shadows.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.65,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Luxury frosted glass color defaults
    final defaultColor = isDark
        ? const Color(0xFF161A18).withValues(alpha: opacity.clamp(0.3, 0.85))
        : const Color(0xFFFAF7F0).withValues(alpha: opacity.clamp(0.4, 0.92));

    final effectiveRadius = borderRadius ?? BorderRadius.circular(24);
    
    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.65),
          width: 1.0,
        );

    final defaultShadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
        blurRadius: 28,
        spreadRadius: -4,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: (isDark ? const Color(0xFF3F6649) : const Color(0xFF172C1E))
            .withValues(alpha: 0.04),
        blurRadius: 40,
        offset: const Offset(0, 12),
      ),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: boxShadow ?? defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? defaultColor,
              borderRadius: effectiveRadius,
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
