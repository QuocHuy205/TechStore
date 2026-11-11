import 'package:flutter/material.dart';

/// Bảng màu thống nhất của ứng dụng TechStore
/// Dựa trên seed color: Color(0xFF1E88E5) - Material3 Blue
class AppColors {
  AppColors._(); // Không cho khởi tạo

  // === Màu chủ đạo ===
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // === Màu nền ===
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // === Màu văn bản ===
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // === Màu trạng thái ===
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // === Màu border ===
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF1E88E5);

  // === Màu đặc biệt ===
  static const Color price = Color(0xFFE53935); // Màu giá - đỏ nổi bật
  static const Color badge = Color(0xFF10B981);  // Màu số lượng - xanh lá
}
