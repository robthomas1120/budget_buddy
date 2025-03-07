// utils/ios_theme.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSTheme {
  // Colors
  static const Color primaryColor = Color(0xFF34C759); // iOS green
  static const Color secondaryColor = Color(0xFF007AFF); // iOS blue
  static const Color destructiveColor = Color(0xFFFF3B30); // iOS red
  static const Color backgroundColor = Color(0xFFF2F2F7); // iOS light gray background
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF000000);
  static const Color secondaryTextColor = Color(0xFF8E8E93);
  static const Color borderColor = Color(0xFFD1D1D6);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: -0.41,
  );
  
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0.37,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: textColor,
    letterSpacing: -0.41,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryTextColor,
    letterSpacing: 0,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: secondaryColor,
    letterSpacing: -0.41,
  );

  // Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration modalDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(14),
  );
  
  static InputDecoration textFieldDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: secondaryColor, width: 1.0),
    ),
  );
}