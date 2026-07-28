import 'dart:ui';
import 'package:flutter/material.dart';

/**
 * Enterprise Glassmorphism Container Widget.
 * Delivers semi-transparent frosted glass aesthetics with subtle specular borders
 * for executive dashboard cards and floating alert overlays.
 */
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 16.0,
    this.blur = 15.0,
    this.opacity = 0.15,
    this.borderColor,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorder = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: width == double.infinity ? null : width,
              height: height == double.infinity ? null : height,
              padding: padding ?? const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(opacity) : Colors.white.withOpacity(opacity * 2),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor ?? defaultBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
