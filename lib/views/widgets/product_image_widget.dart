import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Widget hiển thị hình ảnh sản phẩm từ URL với cache và fallback
class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 72,
    this.height = 72,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    final normalizedUrl = imageUrl.trim();

    if (normalizedUrl.isEmpty || !isValidHttpUrl(normalizedUrl)) {
      return _buildFallbackImage(radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        normalizedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(radius);
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackImage(radius),
      ),
    );
  }

  bool isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _buildFallbackImage(BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: radius,
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: width * 0.52,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: radius,
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
