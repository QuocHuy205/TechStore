import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

/// Service quản lý hình ảnh sản phẩm (ImageService)
///
/// Hỗ trợ cả hai nền tảng: Web và Android
/// Các chức năng:
/// 1. Chọn ảnh từ thư viện thiết bị / máy tính: [pickImageFromGallery]
/// 2. Chụp ảnh từ máy ảnh (Android/Mobile): [pickImageFromCamera]
/// 3. Lấy dữ liệu bytes để xem trước ảnh (Preview) ngay lập tức: [getImageBytes]
/// 4. Tải ảnh lên Cloudinary và nhận URL công khai: [uploadImage]
/// 5. Trả URL ảnh an toàn để lưu vào ProductModel / ProductService
class ImageService {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  /// 1. Chọn hình ảnh từ thư viện thiết bị hoặc tệp tin trên máy tính
  ///
  /// Trả về [XFile] nếu người dùng chọn ảnh, trả về [null] nếu người dùng hủy
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Tối ưu chất lượng ảnh, giảm dung lượng khi upload
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  /// 2. Chụp ảnh mới từ máy ảnh (Hỗ trợ trên Android/Mobile)
  ///
  /// Trả về [XFile] nếu chụp thành công, trả về [null] nếu hủy
  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  /// 3. Đọc dữ liệu bytes của file ảnh để xem trước (Preview)
  ///
  /// Rất quan trọng trên Flutter Web để hiển thị ảnh từ bộ nhớ RAM bằng [Image.memory]
  Future<Uint8List> getImageBytes(XFile imageFile) async {
    return await imageFile.readAsBytes();
  }

  /// 4. Upload file ảnh lên Cloudinary và trả về URL ảnh công khai
  ///
  /// Luồng xử lý:
  ///   XFile -> Đọc Bytes -> FormData -> POST Cloudinary API -> Nhận secure_url
  ///
  /// URL này sau đó được cấp cho [ProductService] để lưu vào Firestore.
  Future<String> uploadImage(XFile imageFile) async {
    return await _cloudinaryService.uploadImage(imageFile);
  }

  /// 5. Kiểm tra một chuỗi có phải là URL hình ảnh hợp lệ hay không
  bool isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }
}
