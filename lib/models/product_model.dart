import 'package:cloud_firestore/cloud_firestore.dart';

/// Model sản phẩm - Ánh xạ với Firestore collection "products"
///
/// BẮT BUỘC: Mỗi document trong Firestore CHỈ có đúng 4 thuộc tính:
///   - name    (String)
///   - price   (Number)
///   - soluong (Integer/Number)
///   - image   (String)
///
/// QUY ĐỊNH:
/// - Document ID được Firestore quản lý riêng, KHÔNG đưa vào dữ liệu lưu trữ (toMap).
/// - Thuộc tính [id] chỉ tồn tại trong bộ nhớ ứng dụng để xác định document.
class ProductModel {
  /// ID document Firestore (quản lý riêng, không lưu vào Firestore document)
  final String id;

  /// 1. Tên sản phẩm (String)
  final String name;

  /// 2. Giá sản phẩm (Number)
  final num price;

  /// 3. Số lượng sản phẩm (Integer)
  final int soluong;

  /// 4. URL hình ảnh sản phẩm (String)
  final String image;

  const ProductModel({
    this.id = '',
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  /// Khởi tạo ProductModel từ Map dữ liệu
  ///
  /// [map]: Map chứa 4 trường từ Firestore document data
  /// [id]: Document ID được truyền riêng từ bên ngoài (nếu có)
  factory ProductModel.fromMap(Map<String, dynamic> map, [String id = '']) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      price: map['price'] as num? ?? 0,
      soluong: (map['soluong'] as num?)?.toInt() ?? 0,
      image: (map['image'] as String?)?.trim() ?? '',
    );
  }

  /// Khởi tạo ProductModel từ DocumentSnapshot của Cloud Firestore
  ///
  /// Tự động tách document ID và trích xuất 4 trường từ doc.data()
  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ProductModel.fromMap(data, doc.id);
  }

  /// Chuyển ProductModel thành Map để lưu vào Cloud Firestore
  ///
  /// QUAN TRỌNG: Chỉ trả về chính xác đúng 4 trường theo quy định bài thi.
  /// Tuyệt đối KHÔNG đưa 'id' hay bất kỳ trường nào khác vào đây.
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'soluong': soluong, 'image': image};
  }

  /// Tạo bản sao với một số thuộc tính được cập nhật
  ProductModel copyWith({
    String? id,
    String? name,
    num? price,
    int? soluong,
    String? image,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      soluong: soluong ?? this.soluong,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, soluong: $soluong, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.soluong == soluong &&
        other.image == image;
  }

  @override
  int get hashCode => Object.hash(id, name, price, soluong, image);
}
