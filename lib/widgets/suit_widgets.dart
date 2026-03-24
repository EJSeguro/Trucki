import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Stateless widget that renders the four card suits as decorative elements
class SuitRow extends StatelessWidget {
  final double size;
  final double opacity;

  const SuitRow({super.key, this.size = 20, this.opacity = 0.7});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Suit('♠', TruckiColors.suitBlack, size, opacity),
        SizedBox(width: size * 0.6),
        _Suit('♥', TruckiColors.suitRed, size, opacity),
        SizedBox(width: size * 0.6),
        _Suit('♦', TruckiColors.suitRed, size, opacity),
        SizedBox(width: size * 0.6),
        _Suit('♣', TruckiColors.suitBlack, size, opacity),
      ],
    );
  }
}

class _Suit extends StatelessWidget {
  final String symbol;
  final Color color;
  final double size;
  final double opacity;

  const _Suit(this.symbol, this.color, this.size, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Text(
      symbol,
      style: TextStyle(
        color: color.withOpacity(opacity),
        fontSize: size,
        shadows: [
          Shadow(
            color: color.withOpacity(opacity * 0.4),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

/// Decorative gold divider with suits
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  TruckiColors.gold.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '✦',
            style: TextStyle(
              color: TruckiColors.gold.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TruckiColors.gold.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gold-bordered card container (Stateless)
class LuxCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final double borderOpacity;
  final List<Color>? gradientColors;

  const LuxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderColor = TruckiColors.gold,
    this.borderOpacity = 0.25,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(borderOpacity),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              [
                TruckiColors.blackCard,
                TruckiColors.blackSurface,
              ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
