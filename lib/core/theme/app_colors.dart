import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E0);

  // Secondary palette
  static const Color secondary = Color(0xFF00BFA6);
  static const Color secondaryLight = Color(0xFF5DF2D6);
  static const Color secondaryDark = Color(0xFF008E76);

  // Category colors — one per dimension
  static const Color processingSpeed = Color(0xFFFF6B6B);
  static const Color workingMemory = Color(0xFF4ECDC4);
  static const Color logicalReasoning = Color(0xFFFFE66D);
  static const Color mathReasoning = Color(0xFF6C63FF);
  static const Color reactionTime = Color(0xFFFF8A5C);
  static const Color attentionControl = Color(0xFF45B7D1);
  static const Color consistencyScore = Color(0xFFA78BFA);

  // Neutral
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F8);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Dark mode
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF25253D);
  static const Color darkTextPrimary = Color(0xFFF8F9FE);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
}
