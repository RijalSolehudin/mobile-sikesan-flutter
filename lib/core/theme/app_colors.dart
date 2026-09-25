import 'package:flutter/material.dart';

class AppColors {
  // Primary Greens
  static const Color primary = Color(0xFF16A34A); // Main Vibrant Green
  static const Color primaryDark = Color(0xFF15803D); // Dark Green
  static const Color primaryLight = Color(0xFF22C55E); // Lighter Green
  static const Color primarySurface = Color(
    0xFFDCFCE7,
  ); // Soft green badge / background
  static const Color primaryEmerald = Color(0xFF10B981); // Emerald

  // Background & Surface
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Off-white / Cool Grey scaffold
  static const Color surface = Color(0xFFFFFFFF); // Pure White Card
  static const Color surfaceMuted = Color(
    0xFFF1F5F9,
  ); // Input / Search background

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B); // Muted grey text
  static const Color textMuted = Color(0xFF94A3B8); // Light grey placeholder
  static const Color textWhite = Color(0xFFFFFFFF);

  // Financial & Feedback Colors
  static const Color expense = Color(0xFFEF4444); // Red for expenses / logout
  static const Color expenseSurface = Color(0xFFFEE2E2); // Light Red background
  static const Color error = Color(0xFFEF4444); // Semantic Error alias
  static const Color income = Color(0xFF16A34A); // Green for incomes
  static const Color incomeSurface = Color(
    0xFFDCFCE7,
  ); // Light Green background

  // Dark Slate / Filter Active
  static const Color darkSlate = Color(0xFF1E293B);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Category Icon Colors
  static const Color iconBlue = Color(0xFF3B82F6);
  static const Color iconOrange = Color(0xFFF97316);
  static const Color iconPurple = Color(0xFF8B5CF6);
  static const Color iconGreen = Color(0xFF10B981);
  static const Color iconRed = Color(0xFFEF4444);
}
