import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import 'product_image_widget.dart';

/// Card hiển thị sản phẩm tối ưu hóa riêng cho màn hình Mobile (Android)
///
/// Hiển thị đầy đủ 4 trường dữ liệu theo quy định:
/// 1. Hình ảnh sản phẩm (image)
/// 2. Tên sản phẩm (name)
/// 3. Giá sản phẩm (price - định dạng VNĐ)
/// 4. Số lượng tồn kho (soluong)
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool inStock = product.soluong > 0;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200, width: 0.8),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. HÌNH ẢNH SẢN PHẨM (84x84 dp, bo góc 10dp)
              Hero(
                tag: 'product_image_${product.id}',
                child: ProductImageWidget(
                  imageUrl: product.image,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),

              // 2. THÔNG TIN SẢN PHẨM: Tên, Giá, Số lượng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tên sản phẩm
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Giá sản phẩm (Đỏ nổi bật, format VNĐ)
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.price,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Số lượng tồn kho (Badge trạng thái)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: inStock
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                inStock ? Icons.inventory_2_outlined : Icons.remove_circle_outline,
                                size: 12,
                                color: inStock ? AppColors.success : AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                inStock ? 'Còn ${product.soluong} cái' : 'Hết hàng (0)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: inStock ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. THAO TÁC SỬA / XÓA (Cột dọc gọn gàng trên mobile)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: AppColors.primary,
                      tooltip: AppStrings.editProduct,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.error,
                      tooltip: AppStrings.deleteProduct,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
