import 'package:intl/intl.dart';

/// Tiện ích định dạng tiền tệ Việt Nam Đồng
class CurrencyFormatter {
  CurrencyFormatter._(); // Không cho khởi tạo

  // Định dạng: 350.000 ₫
  static final NumberFormat _vnFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Định dạng số thành chuỗi tiền VNĐ
  /// Ví dụ: 350000 → "350.000 ₫"
  static String format(num value) {
    return _vnFormat.format(value);
  }

  /// Parse chuỗi về số (bỏ ký tự format)
  /// Ví dụ: "350.000" → 350000.0
  static double? tryParse(String text) {
    // Bỏ dấu chấm phân cách hàng nghìn và ký hiệu ₫
    final cleaned = text.replaceAll('.', '').replaceAll('₫', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }
}
