import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Service quản lý nghiệp vụ sản phẩm trực tiếp với Cloud Firestore
///
/// Collection: "products"
/// Quy định nghiệp vụ:
/// - getProducts: Hỗ trợ cả Stream thời gian thực và Future lấy danh sách
/// - addProduct: Thêm document mới (Firestore tự sinh ID, chỉ lưu đúng 4 trường)
/// - updateProduct: Cập nhật đúng document theo ID (chỉ cập nhật 4 trường)
/// - deleteProduct: XÓA THẬT document khỏi Firestore (Hard Delete)
/// - TUYỆT ĐỐI không soft-delete, không tạo bảng lưu trữ archive/restore
class ProductService {
  /// Tham chiếu đến collection "products" trong Cloud Firestore
  final CollectionReference<Map<String, dynamic>> _productsRef =
      FirebaseFirestore.instance.collection('products');

  /// 1. Lấy Stream danh sách sản phẩm theo thời gian thực (Real-time Stream)
  ///
  /// Tự động cập nhật danh sách khi có thay đổi trên Firestore.
  /// Sắp xếp tăng dần theo tên sản phẩm [name].
  Stream<List<ProductModel>> getProductsStream() {
    return _productsRef
        .orderBy('name')
        .withConverter<ProductModel>(
          fromFirestore: (snapshot, _) => ProductModel.fromFirestore(snapshot),
          toFirestore: (product, _) => product.toMap(),
        )
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// 2. Lấy danh sách sản phẩm một lần (Future)
  ///
  /// Phù hợp khi cần đọc dữ liệu tĩnh hoặc kiểm thử độc lập.
  Future<List<ProductModel>> getProducts() async {
    final querySnapshot = await _productsRef.orderBy('name').get();
    return querySnapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  /// 3. Lấy thông tin một sản phẩm cụ thể theo Document ID
  Future<ProductModel?> getProductById(String id) async {
    if (id.trim().isEmpty) return null;
    final doc = await _productsRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return ProductModel.fromFirestore(doc);
  }

  /// 4. Thêm sản phẩm mới vào Firestore
  ///
  /// - Firestore sẽ tự sinh Document ID duy nhất.
  /// - Chỉ lưu chính xác 4 trường từ [product.toMap()]: name, price, soluong, image.
  /// - Trả về Document ID vừa được tạo.
  Future<String> addProduct(ProductModel product) async {
    // toMap() đảm bảo chỉ có 4 trường: name, price, soluong, image
    final docRef = await _productsRef.add(product.toMap());
    return docRef.id;
  }

  /// 5. Cập nhật thông tin sản phẩm theo Document ID
  ///
  /// - Cập nhật đúng document có ID = [id].
  /// - Chỉ cập nhật 4 trường dữ liệu, không làm thay đổi ID hay thêm trường mới.
  Future<void> updateProduct(String id, ProductModel product) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Document ID không được để trống khi cập nhật sản phẩm.');
    }
    await _productsRef.doc(id).update(product.toMap());
  }

  /// 6. Xóa thật sản phẩm khỏi Firestore (Hard Delete)
  ///
  /// - Xóa vĩnh viễn document có ID = [id].
  /// - KHÔNG tạo cờ đánh dấu xóa tạm thời (isDeleted).
  /// - KHÔNG chuyển sang collection thùng rác hay archive.
  Future<void> deleteProduct(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Document ID không được để trống khi xóa sản phẩm.');
    }
    await _productsRef.doc(id).delete();
  }
}
