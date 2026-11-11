import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/cloudinary_config.dart';
import '../../core/utils/validator.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../services/cloudinary_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_image_widget.dart';

/// Form thêm / sửa sản phẩm
///
/// [product] = null → chế độ Thêm mới
/// [product] != null → chế độ Sửa
class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  final VoidCallback? onSuccess;

  const ProductFormScreen({super.key, this.product, this.onSuccess});

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _soluongController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _cloudinaryService = CloudinaryService();

  // Chế độ nhập ảnh: 0: Chọn file từ máy (Upload Cloudinary), 1: Nhập URL trực tiếp
  int _imageInputMode = 0;

  // Trạng thái ảnh được chọn
  XFile? _selectedImageFile; // File ảnh vừa chọn
  Uint8List? _selectedImageBytes; // Bytes để hiển thị preview (Web)
  String _currentImageUrl =
      ''; // URL ảnh hiện tại (khi edit hoặc khi paste URL)

  bool _isUploading = false;
  bool _isSaving = false;
  String _savingStatus = '';

  @override
  void initState() {
    super.initState();
    // Nếu đang sửa, nạp dữ liệu hiện tại vào form
    if (widget.isEditing) {
      final p = widget.product!;
      _nameController.text = p.name;
      _priceController.text = p.price.toInt().toString();
      _soluongController.text = p.soluong.toString();
      _currentImageUrl = p.image;
      _imageUrlController.text = p.image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _soluongController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactLayout = screenWidth < 520;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;

        return Padding(
          padding: EdgeInsets.all(compact ? 12 : (isCompactLayout ? 16 : 24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === TIÊU ĐỀ & NÚT ĐÓNG ===
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_box_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing
                                ? AppStrings.editProduct
                                : AppStrings.addProduct,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.isEditing
                                ? 'Chỉnh sửa thông tin sản phẩm và cập nhật'
                                : 'Nhập thông tin sản phẩm mới vào hệ thống',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      tooltip: 'Đóng',
                    ),
                  ],
                ),
                const Divider(height: 24),

                // === FORM CHÍNH ===
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tên sản phẩm
                          _buildFieldLabel('Tên sản phẩm *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            enabled: !_isSaving,
                            decoration: _inputDecoration(
                              hintText: AppStrings.productNameHint,
                              prefixIcon: Icons.shopping_bag_outlined,
                            ),
                            validator: Validator.validateName,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // Giá và Số lượng (2 cột)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Giá
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Giá bán (VNĐ) *'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _priceController,
                                      enabled: !_isSaving,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(
                                        hintText: 'VD: 350000',
                                        prefixIcon: Icons.payments_outlined,
                                      ),
                                      validator: Validator.validatePrice,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Số lượng
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Số lượng tồn kho *'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _soluongController,
                                      enabled: !_isSaving,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(
                                        hintText: 'VD: 15',
                                        prefixIcon: Icons.inventory_2_outlined,
                                      ),
                                      validator: Validator.validateSoluong,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // === PHẦN HÌNH ẢNH SẢN PHẨM ===
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFieldLabel('Hình ảnh sản phẩm *'),
                              _buildCloudinaryStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: 8),

                          _buildImageSourceSelector(),
                          const SizedBox(height: 12),

                          _buildImageSection(),
                          const SizedBox(height: 24),

                          if (_isSaving) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _savingStatus.isNotEmpty
                                          ? _savingStatus
                                          : 'Đang xử lý...',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(AppStrings.cancel),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: _isSaving ? null : _handleSave,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isUploading
                                              ? AppStrings.uploadingImage
                                              : (widget.isEditing
                                                    ? 'Cập nhật sản phẩm'
                                                    : AppStrings.saveProduct),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Badge trạng thái cấu hình Cloudinary
  Widget _buildCloudinaryStatusBadge() {
    final configured = CloudinaryConfig.isConfigured;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: configured
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: configured ? AppColors.success : AppColors.warning,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            configured ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            size: 13,
            color: configured ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            configured
                ? 'Cloudinary: ${CloudinaryConfig.cloudName}'
                : 'Cloudinary chưa kích hoạt',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: configured ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  /// Bộ chọn cách nhập ảnh
  Widget _buildImageSourceSelector() {
    final compact = MediaQuery.of(context).size.width < 420;

    final children = [
      Expanded(
        child: InkWell(
          onTap: _isSaving ? null : () => setState(() => _imageInputMode = 0),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _imageInputMode == 0 ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: _imageInputMode == 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 16,
                  color: _imageInputMode == 0
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Tải ảnh lên máy (Cloudinary)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 10 : 12,
                      fontWeight: _imageInputMode == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _imageInputMode == 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Expanded(
        child: InkWell(
          onTap: _isSaving ? null : () => setState(() => _imageInputMode = 1),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _imageInputMode == 1 ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: _imageInputMode == 1
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 16,
                  color: _imageInputMode == 1
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Dán liên kết (URL)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 10 : 12,
                      fontWeight: _imageInputMode == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _imageInputMode == 1
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(children: children),
    );
  }

  /// Section chọn và xem trước ảnh
  Widget _buildImageSection() {
    final hasNewFile =
        _selectedImageBytes != null || _selectedImageFile != null;
    final effectiveUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : _currentImageUrl;
    final hasExistingUrl = effectiveUrl.isNotEmpty;
    final isCompactLayout = MediaQuery.of(context).size.width < 520;

    if (isCompactLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.background,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hasNewFile
                    ? _buildNewImagePreview()
                    : hasExistingUrl
                    ? ProductImageWidget(
                        imageUrl: effectiveUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 36,
                              color: AppColors.textHint,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Chưa có ảnh',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _imageInputMode == 0
              ? _buildUploadFileControls(hasNewFile)
              : _buildUrlInputControls(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            color: AppColors.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasNewFile
                ? _buildNewImagePreview()
                : hasExistingUrl
                ? ProductImageWidget(
                    imageUrl: effectiveUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chưa có ảnh',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _imageInputMode == 0
              ? _buildUploadFileControls(hasNewFile)
              : _buildUrlInputControls(),
        ),
      ],
    );
  }

  /// Nút chọn file ảnh từ máy
  Widget _buildUploadFileControls(bool hasNewFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(hasNewFile ? 'Đổi ảnh khác' : AppStrings.selectImage),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
            if (!kIsWeb)
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickFromCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text(AppStrings.captureImage),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            if (hasNewFile)
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _selectedImageFile = null;
                          _selectedImageBytes = null;
                        });
                      },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                label: const Text(
                  'Bỏ chọn',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasNewFile && _selectedImageFile != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Đã chọn: ${_selectedImageFile!.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
        const Text(
          'Ảnh sẽ tự động tải lên Cloudinary khi bấm Lưu\nĐịnh dạng: JPG, PNG, WEBP (Tối đa 10MB)',
          style: TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
      ],
    );
  }

  /// Ô nhập URL ảnh trực tiếp
  Widget _buildUrlInputControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _imageUrlController,
          enabled: !_isSaving,
          decoration:
              _inputDecoration(
                hintText: 'https://example.com/image.jpg',
                prefixIcon: Icons.link,
              ).copyWith(
                suffixIcon: _imageUrlController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _imageUrlController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
          onChanged: (val) {
            setState(() {
              // Xóa file chọn nếu nhập URL trực tiếp
              _selectedImageFile = null;
              _selectedImageBytes = null;
            });
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Dán liên kết ảnh từ web để dùng trực tiếp mà không cần upload lại.',
          style: TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildNewImagePreview() {
    // Trên Web: dùng bytes
    if (kIsWeb && _selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }
    // Trên Android/Mobile: dùng file path
    if (!kIsWeb && _selectedImageFile != null) {
      return Image.network(
        _selectedImageFile!.path,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined),
      );
    }
    return const SizedBox.shrink();
  }

  // === Chọn ảnh từ thư viện ===
  Future<void> _pickFromGallery() async {
    final file = await _cloudinaryService.pickImageFromGallery();
    if (file != null) {
      await _loadSelectedImage(file);
    }
  }

  // === Chụp ảnh từ camera ===
  Future<void> _pickFromCamera() async {
    final file = await _cloudinaryService.pickImageFromCamera();
    if (file != null) {
      await _loadSelectedImage(file);
    }
  }

  Future<void> _loadSelectedImage(XFile file) async {
    // Đọc bytes
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImageFile = file;
      _selectedImageBytes = bytes;
      _imageInputMode = 0; // Chuyển về tab upload
    });
  }

  // === Lưu sản phẩm ===
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final typedUrl = _imageUrlController.text.trim();
    final hasNewFile = _selectedImageFile != null;
    final hasDirectUrl = typedUrl.isNotEmpty;
    final hasExistingUrl = _currentImageUrl.isNotEmpty;

    // Kiểm tra có ảnh không
    if (!hasNewFile && !hasDirectUrl && !hasExistingUrl) {
      showErrorSnackBar(context, AppStrings.errorImageRequired);
      return;
    }

    setState(() {
      _isSaving = true;
      _savingStatus = 'Đang chuẩn bị dữ liệu...';
    });

    // Lưu reference provider trước các await để tránh BuildContext async gap
    final productProvider = context.read<ProductProvider>();

    try {
      String finalImageUrl = hasDirectUrl ? typedUrl : _currentImageUrl;

      // Nếu có chọn file ảnh mới -> upload lên Cloudinary
      if (hasNewFile) {
        setState(() {
          _isUploading = true;
          _savingStatus = 'Đang tải ảnh lên Cloudinary...';
        });

        if (!CloudinaryConfig.isConfigured) {
          throw Exception(
            'Cloudinary chưa được kích hoạt hợp lệ trong cloudinary_config.dart',
          );
        }

        finalImageUrl = await _cloudinaryService.uploadImage(
          _selectedImageFile!,
        );

        setState(() {
          _isUploading = false;
          _savingStatus = 'Tải ảnh thành công. Đang lưu vào Firestore...';
        });
      } else {
        setState(() {
          _savingStatus = 'Đang lưu vào Firestore...';
        });
      }

      // Parse dữ liệu form
      final priceStr = _priceController.text
          .replaceAll('.', '')
          .replaceAll(',', '')
          .trim();
      final price = num.parse(priceStr);
      final soluong = int.parse(_soluongController.text.trim());

      // Tạo ProductModel với đúng 4 trường theo quy định bài thi:
      // name, price, soluong, image
      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        price: price,
        soluong: soluong,
        image: finalImageUrl,
      );

      bool success;
      String successMsg;

      if (widget.isEditing) {
        // Sửa sản phẩm
        success = await productProvider.updateProduct(
          widget.product!.id,
          product,
        );
        successMsg = AppStrings.updateSuccess;
      } else {
        // Thêm sản phẩm mới
        success = await productProvider.addProduct(product);
        successMsg = AppStrings.addSuccess;
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (success) {
        widget.onSuccess?.call();
        showSuccessSnackBar(context, successMsg);
      } else {
        final error = productProvider.errorMessage ?? AppStrings.errorUnknown;
        showErrorSnackBar(context, error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isUploading = false;
      });
      showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  // === Helpers ===
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
