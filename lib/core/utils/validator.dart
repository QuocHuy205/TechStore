import '../constants/app_strings.dart';

/// Tiện ích kiểm tra và xác thực dữ liệu (Validation)
///
/// Các quy tắc theo yêu cầu bài thi:
/// 1. Tên sản phẩm không được để trống.
/// 2. Giá phải là số hợp lệ và lớn hơn 0 (không âm).
/// 3. Số lượng phải là số nguyên không âm (>= 0), KHÔNG được là số thập phân.
/// 4. Hình ảnh phải có URL hợp lệ trước khi lưu vào Firestore.
class Validator {
  Validator._(); // Ngăn việc khởi tạo instance

  /// 1. Validate tên sản phẩm: Không được để trống, tối thiểu 2 ký tự
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    if (value.trim().length < 2) {
      return 'Tên sản phẩm phải có ít nhất 2 ký tự';
    }
    return null;
  }

  /// 2. Validate giá sản phẩm: Phải là số hợp lệ và lớn hơn 0
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    // Cho phép format dấu chấm phân cách hàng nghìn kiểu VN (VD: 350.000)
    final cleaned = value.replaceAll('.', '').replaceAll(',', '').trim();
    final parsed = num.tryParse(cleaned);
    if (parsed == null) {
      return AppStrings.errorInvalidPrice;
    }
    if (parsed <= 0) {
      return 'Giá sản phẩm phải lớn hơn 0 VNĐ';
    }
    return null;
  }

  /// 3. Validate số lượng sản phẩm: Phải là số nguyên không âm (>= 0), KHÔNG chấp nhận số thập phân
  static String? validateSoluong(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    final trimmed = value.trim();

    // Không chấp nhận số thập phân (ví dụ: 15.5 hoặc 15,5)
    if (trimmed.contains('.') || trimmed.contains(',')) {
      return 'Số lượng phải là số nguyên (không được chứa số thập phân)';
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return AppStrings.errorInvalidQuantity;
    }
    if (parsed < 0) {
      return 'Số lượng sản phẩm không được âm (>= 0)';
    }
    return null;
  }

  /// 4. Validate URL hình ảnh: Phải là địa chỉ URL hợp lệ (http hoặc https)
  static String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorImageRequired;
    }

    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Đường dẫn hình ảnh phải là URL hợp lệ (http:// hoặc https://)';
    }
    return null;
  }

  /// 5. Validate Email (dùng cho đăng nhập Admin)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ email không đúng định dạng';
    }
    return null;
  }

  /// 6. Validate Mật khẩu (dùng cho đăng nhập Admin)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorRequired;
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
}
