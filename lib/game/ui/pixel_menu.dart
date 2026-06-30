import 'package:flutter/material.dart';

import '../../theme/text_styles.dart';
import '../config/palette.dart';

class PixelMenuBackdrop extends StatelessWidget {
  final Widget child;
  final bool showBackground;

  const PixelMenuBackdrop({
    super.key,
    required this.child,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showBackground)
          Image.asset('assets/images/background.png', fit: BoxFit.cover),
        Container(color: const Color(0xB0102430)),
        Center(child: child),
      ],
    );
  }
}

class PixelPanel extends StatelessWidget {
  final double width;
  final EdgeInsets padding;
  final List<Widget> children;

  const PixelPanel({
    super.key,
    required this.children,
    this.width = 360,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xE51B3948),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8D189), width: 3),
        boxShadow: const [
          BoxShadow(
              offset: Offset(0, 7), blurRadius: 0, color: Color(0xFF0B1C24)),
          BoxShadow(
              offset: Offset(0, 12), blurRadius: 18, color: Color(0x90000000)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class PixelMenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double fontSize;
  final bool danger;

  const PixelMenuButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.width = 260,
    this.height = 50,
    this.fontSize = 16,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: danger ? const Color(0xFF5E2D2D) : const Color(0xFF284F62),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF9FC4D4), width: 2),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 4), blurRadius: 0, color: Color(0xFF102631))
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.pixelFont(fontSize, color).copyWith(
              shadows: const [
                Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.black)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PixelMenuTitle extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const PixelMenuTitle({
    super.key,
    required this.text,
    this.color = Palette.starColor,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.pixelFont(size, color).copyWith(
        shadows: const [
          Shadow(offset: Offset(3, 3), blurRadius: 0, color: Color(0xFF8B4513))
        ],
      ),
    );
  }
}

class PixelMenuText extends StatelessWidget {
  final String text;
  final double size;

  const PixelMenuText({super.key, required this.text, this.size = 11});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.pixelFont(size, Colors.white).copyWith(
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.black)
        ],
      ),
    );
  }
}
