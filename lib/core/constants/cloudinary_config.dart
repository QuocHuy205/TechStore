/// Cấu hình Cloudinary
///
/// HƯỚNG DẪN:
/// 1. Đăng nhập https://cloudinary.com
/// 2. Vào Settings → Upload → Upload Presets → Add upload preset
/// 3. Chọn "Unsigned" và đặt tên preset
/// 4. Copy Cloud Name từ Dashboard
/// 5. Điền vào hai hằng số bên dưới
///
/// QUAN TRỌNG: Không để API Secret ở đây (chỉ dùng Unsigned preset)
class CloudinaryConfig {
  CloudinaryConfig._();

  /// Cloud Name của tài khoản Cloudinary (lấy từ Dashboard)
  static const String cloudName = 'dkmllunui';

  /// Tên Upload Preset (Unsigned) đã tạo trong Cloudinary Settings
  static const String uploadPreset = 'techstore_preset';

  /// URL API upload Cloudinary
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Kiểm tra đã cấu hình chưa (không rỗng và không phải giá trị placeholder mặc định)
  static bool get isConfigured =>
      cloudName.trim().isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset.trim().isNotEmpty &&
      uploadPreset != 'YOUR_UPLOAD_PRESET';
}
