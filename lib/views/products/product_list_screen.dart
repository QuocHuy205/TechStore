import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;
import '../widgets/common_widgets.dart' as cw;
import '../widgets/product_image_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_sheet.dart';
import 'product_form_screen.dart';

/// Màn hình danh sách sản phẩm - Responsive hoàn toàn cho cả Web và Android
///
/// - Trên Web / Desktop (width >= 768dp): Hiển thị bảng DataTable quản trị viên.
/// - Trên Android / Mobile (width < 768dp): Hiển thị danh sách ProductCard đẹp mắt.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === TOOLBAR: TÌM KIẾM & NÚT THÊM SẢN PHẨM ===
            _buildToolbar(isMobile),
            SizedBox(height: isMobile ? 12 : 18),

            // === DANH SÁCH / BẢNG SẢN PHẨM ===
            Expanded(child: _buildProductContent(isMobile)),
          ],
        ),
      ),
      // FAB trên Mobile để thêm sản phẩm dễ dàng bằng ngón cái
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: _openAddProduct,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Thêm sản phẩm'),
            )
          : null,
    );
  }

  /// Toolbar tìm kiếm và nút thêm
  Widget _buildToolbar(bool isMobile) {
    return Row(
      children: [
        // Ô tìm kiếm sản phẩm theo tên
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: isMobile
                  ? 'Tìm tên phụ kiện...'
                  : AppStrings.searchHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ProductProvider>().setSearchQuery('');
                    },
                  );
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) {
              context.read<ProductProvider>().setSearchQuery(value);
            },
          ),
        ),

        // Nút thêm sản phẩm trên Desktop/Web (ẩn trên mobile vì đã có FAB)
        if (!isMobile) ...[
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: _openAddProduct,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addProduct),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Nội dung danh sách sản phẩm từ Stream Cloud Firestore
  Widget _buildProductContent(bool isMobile) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        return StreamBuilder<List<ProductModel>>(
          stream: productProvider.productsStream,
          builder: (context, snapshot) {
            // === 1. TRẠNG THÁI LOADING ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(
                message: 'Đang tải danh sách sản phẩm...',
              );
            }

            // === 2. TRẠNG THÁI LỖI ===
            if (snapshot.hasError) {
              return cw.ErrorWidget(
                message: snapshot.error.toString(),
                onRetry: () => setState(() {}),
              );
            }

            // === 3. LỌC TÌM KIẾM ===
            final allProducts = snapshot.data ?? [];
            final products = productProvider.filterProducts(allProducts);

            // === 4. TRẠNG THÁI RỖNG ===
            if (products.isEmpty) {
              if (_searchController.text.isNotEmpty) {
                return EmptyWidget(
                  message:
                      'Không tìm thấy sản phẩm khớp với\n"${_searchController.text}"',
                  icon: Icons.search_off_rounded,
                );
              }
              return EmptyWidget(
                message: AppStrings.noProducts,
                actionLabel: AppStrings.addProduct,
                onAction: _openAddProduct,
              );
            }

            // === 5. HIỂN THỊ DỮ LIỆU ===
            // Mobile (Android): Hiển thị Product Card dạng danh sách cuộn
            if (isMobile) {
              return _buildMobileProductList(products);
            }

            // Web: Hiển thị DataTable dạng bảng quản trị
            return _buildWebProductTable(products);
          },
        );
      },
    );
  }

  /// Giao diện dành riêng cho Mobile (Android)
  Widget _buildMobileProductList(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Có tất cả ${products.length} sản phẩm',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            // Thêm padding dưới để không bị che bởi FAB
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => _showProductDetails(product),
                onEdit: () => _openEditProduct(product),
                onDelete: () => _confirmDelete(product),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Giao diện dành riêng cho Web (DataTable)
  Widget _buildWebProductTable(List<ProductModel> products) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Tổng cộng ${products.length} sản phẩm',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 48 - 220 - 24,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.background,
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    dataTextStyle: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    headingRowHeight: 52,
                    dataRowMinHeight: 96,
                    dataRowMaxHeight: 118,
                    columnSpacing: 18,
                    horizontalMargin: 16,
                    dividerThickness: 0.8,
                    columns: const [
                      DataColumn(
                        label: SizedBox(width: 140, child: Text('Hình ảnh')),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 260,
                          child: Text('Tên sản phẩm'),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(width: 120, child: Text('Giá bán')),
                        numeric: true,
                      ),
                      DataColumn(
                        label: SizedBox(width: 110, child: Text('Tồn kho')),
                        numeric: true,
                      ),
                      DataColumn(
                        label: SizedBox(width: 110, child: Text('Thao tác')),
                      ),
                    ],
                    rows: products.map((product) {
                      return _buildDataRow(product);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(ProductModel product) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 140,
            child: Center(
              child: ProductImageWidget(
                imageUrl: product.image,
                width: 100,
                height: 100,
                borderRadius: BorderRadius.circular(14),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              CurrencyFormatter.format(product.price),
              style: const TextStyle(
                color: AppColors.price,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: product.soluong > 0
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${product.soluong}',
                  style: TextStyle(
                    color: product.soluong > 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.primary,
                  tooltip: AppStrings.editProduct,
                  onPressed: () => _openEditProduct(product),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  tooltip: AppStrings.deleteProduct,
                  onPressed: () => _confirmDelete(product),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Xem chi tiết sản phẩm trên Mobile bằng BottomSheet
  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductDetailSheet(
        product: product,
        onEdit: () => _openEditProduct(product),
        onDelete: () => _confirmDelete(product),
      ),
    );
  }

  /// Mở form thêm sản phẩm
  void _openAddProduct() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 540.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: dialogWidth,
          child: ProductFormScreen(onSuccess: () => Navigator.of(ctx).pop()),
        ),
      ),
    );
  }

  /// Mở form sửa sản phẩm
  void _openEditProduct(ProductModel product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 540.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: dialogWidth,
          child: ProductFormScreen(
            product: product,
            onSuccess: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  /// Hộp thoại xác nhận xóa sản phẩm (Hard delete)
  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text(AppStrings.deleteConfirmTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.deleteConfirmMessage),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.deleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<ProductProvider>().deleteProduct(
        product.id,
      );
      if (mounted) {
        if (success) {
          showSuccessSnackBar(context, AppStrings.deleteSuccess);
        } else {
          final error =
              context.read<ProductProvider>().errorMessage ?? 'Xóa thất bại';
          showErrorSnackBar(context, error);
        }
      }
    }
  }
}
