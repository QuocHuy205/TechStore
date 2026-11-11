import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// Provider quản lý trạng thái danh sách sản phẩm
/// Dùng với Provider package (ChangeNotifier)
class ProductProvider extends ChangeNotifier {
  ProductProvider({
    ProductService? productService,
    Stream<List<ProductModel>>? productsStream,
  }) : _productService = productService,
       _productsStreamOverride = productsStream;

  final ProductService? _productService;
  final Stream<List<ProductModel>>? _productsStreamOverride;

  ProductService get _service => _productService ?? ProductService();

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // === Getters ===
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Stream sản phẩm theo thời gian thực từ Firestore
  Stream<List<ProductModel>> get productsStream =>
      _productsStreamOverride ?? _service.getProductsStream();

  /// Thêm sản phẩm mới
  ///
  /// Trả về [true] nếu thành công.
  Future<bool> addProduct(ProductModel product) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.addProduct(product);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Thêm sản phẩm thất bại: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật sản phẩm theo ID
  ///
  /// Trả về [true] nếu thành công.
  Future<bool> updateProduct(String id, ProductModel product) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.updateProduct(id, product);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật sản phẩm thất bại: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Xóa thật sản phẩm khỏi Firestore (Hard delete)
  ///
  /// Trả về [true] nếu thành công.
  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.deleteProduct(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Xóa sản phẩm thất bại: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật từ khóa tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  /// Lọc danh sách sản phẩm theo từ khóa tìm kiếm
  List<ProductModel> filterProducts(List<ProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // === Private helpers ===
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
