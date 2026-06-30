import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle pixelFont(double size, Color color, {double letterSpacing = 0}) {
    return TextStyle(
      fontFamily: 'PixelFont',
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle hudProgress(bool collected, Color collectedColor, Color pendingColor) {
    return pixelFont(14, collected ? collectedColor : pendingColor);
  }
}
