import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/cloudinary_config.dart';

/// Service upload hình ảnh lên Cloudinary
///
/// Dùng Unsigned Upload Preset — KHÔNG cần API Secret trong Flutter.
/// Luồng: Chọn ảnh → Đọc bytes → POST lên Cloudinary → Nhận URL
class CloudinaryService {
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();

  /// Chọn ảnh từ thư viện thiết bị / máy tính
  ///
  /// Trả về [XFile] nếu người dùng chọn, [null] nếu hủy
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Nén nhẹ để tăng tốc upload
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  /// Chụp ảnh từ camera (dùng trên Android)
  ///
  /// Trả về [XFile] nếu chụp thành công, [null] nếu hủy
  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  /// Upload ảnh lên Cloudinary và trả về URL công khai
  ///
  /// [imageFile]: File ảnh đã chọn (từ pickImage)
  /// Trả về URL String nếu thành công
  /// Ném Exception nếu thất bại
  Future<String> uploadImage(XFile imageFile) async {
    // Đọc bytes của file ảnh
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final String rawName = imageFile.name.trim();
    final String fileName = rawName.isNotEmpty
        ? rawName
        : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Tạo FormData để POST lên Cloudinary
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
      ),
      'upload_preset': CloudinaryConfig.uploadPreset,
      'folder': 'techstore',
    });

    try {
      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Lấy URL ảnh đã upload từ response
        final String imageUrl = response.data['secure_url'] as String;
        return imageUrl;
      } else {
        throw Exception('Upload thất bại: status ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Hết thời gian kết nối đến Cloudinary. Vui lòng kiểm tra mạng và thử lại.');
      }
      
      // Lấy thông báo lỗi chi tiết từ server Cloudinary nếu có
      String serverError = '';
      if (e.response?.data is Map) {
        serverError = e.response?.data['error']?['message']?.toString() ?? '';
      }
      
      if (serverError.isNotEmpty) {
        throw Exception('Lỗi từ Cloudinary: $serverError');
      }
      throw Exception('Lỗi upload ảnh: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('Lỗi khi tải ảnh lên Cloudinary: $e');
    }
  }
}
