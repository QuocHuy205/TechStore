import 'package:flutter_test/flutter_test.dart';
import 'package:techstore/models/product_model.dart';
import 'package:techstore/core/utils/validator.dart';
import 'package:techstore/core/constants/cloudinary_config.dart';
import 'package:techstore/services/image_service.dart';

void main() {
  group('1. ProductModel - Kiểm thử cấu trúc và tính toàn vẹn 4 trường', () {
    test('ProductModel.fromMap phải ánh xạ chính xác 4 thuộc tính và ID', () {
      final mapData = {
        'name': 'Tai nghe Bluetooth không dây',
        'price': 450000,
        'soluong': 25,
        'image': 'https://res.cloudinary.com/dkmllunui/image/upload/sample.jpg',
      };

      final product = ProductModel.fromMap(mapData, 'doc_id_123');

      expect(product.id, equals('doc_id_123'));
      expect(product.name, equals('Tai nghe Bluetooth không dây'));
      expect(product.price, equals(450000));
      expect(product.soluong, equals(25));
      expect(product.image, equals('https://res.cloudinary.com/dkmllunui/image/upload/sample.jpg'));
    });

    test('ProductModel.toMap CHỈ ĐƯỢC CHỨA CHÍNH XÁC 4 TRƯỜNG theo yêu cầu đề bài', () {
      const product = ProductModel(
        id: 'auto_generated_id_999',
        name: 'Cáp sạc Type-C 60W',
        price: 85000,
        soluong: 100,
        image: 'https://res.cloudinary.com/dkmllunui/image/upload/cable.jpg',
      );

      final map = product.toMap();

      // Kiểm tra số lượng keys chính xác bằng 4
      expect(map.length, equals(4));

      // Kiểm tra 4 keys bắt buộc
      expect(map.containsKey('name'), isTrue);
      expect(map.containsKey('price'), isTrue);
      expect(map.containsKey('soluong'), isTrue);
      expect(map.containsKey('image'), isTrue);

      // QUAN TRỌNG: Document ID TUYỆT ĐỐI không được nằm trong toMap
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('isDeleted'), isFalse);

      // Kiểm tra kiểu dữ liệu của từng giá trị
      expect(map['name'], isA<String>());
      expect(map['price'], isA<num>());
      expect(map['soluong'], isA<int>());
      expect(map['image'], isA<String>());
    });

    test('ProductModel.copyWith phải sao chép và cập nhật đúng thuộc tính', () {
      const initial = ProductModel(
        id: '1',
        name: 'Củ sạc nhanh 20W',
        price: 150000,
        soluong: 10,
        image: 'https://example.com/charger.jpg',
      );

      final updated = initial.copyWith(
        price: 180000,
        soluong: 8,
      );

      expect(updated.id, equals('1'));
      expect(updated.name, equals('Củ sạc nhanh 20W'));
      expect(updated.price, equals(180000));
      expect(updated.soluong, equals(8));
      expect(updated.image, equals('https://example.com/charger.jpg'));
    });
  });

  group('2. Validator - Kiểm thử tính hợp lệ của dữ liệu đầu vào', () {
    test('Validate tên sản phẩm: Không rỗng và tối thiểu 2 ký tự', () {
      expect(Validator.validateName(null), isNotNull);
      expect(Validator.validateName(''), isNotNull);
      expect(Validator.validateName('  '), isNotNull);
      expect(Validator.validateName('A'), isNotNull);
      expect(Validator.validateName('Ốp lưng'), isNull);
    });

    test('Validate giá sản phẩm: Phải là số hợp lệ và lớn hơn 0', () {
      expect(Validator.validatePrice(null), isNotNull);
      expect(Validator.validatePrice(''), isNotNull);
      expect(Validator.validatePrice('abc'), isNotNull);
      expect(Validator.validatePrice('-50000'), isNotNull);
      expect(Validator.validatePrice('0'), isNotNull);
      expect(Validator.validatePrice('350000'), isNull);
      expect(Validator.validatePrice('1.500.000'), isNull); // Hỗ trợ format có dấu chấm
    });

    test('Validate số lượng sản phẩm: Phải là số nguyên không âm (>= 0)', () {
      expect(Validator.validateSoluong(null), isNotNull);
      expect(Validator.validateSoluong(''), isNotNull);
      expect(Validator.validateSoluong('-1'), isNotNull);
      expect(Validator.validateSoluong('abc'), isNotNull);
      expect(Validator.validateSoluong('0'), isNull);  // Tồn kho 0 là hợp lệ
      expect(Validator.validateSoluong('15'), isNull); // Số nguyên dương
    });

    test('Validate URL hình ảnh: Phải là địa chỉ URL hợp lệ', () {
      expect(Validator.validateImageUrl(null), isNotNull);
      expect(Validator.validateImageUrl(''), isNotNull);
      expect(Validator.validateImageUrl('not_a_url'), isNotNull);
      expect(Validator.validateImageUrl('ftp://example.com/image.jpg'), isNotNull);
      expect(Validator.validateImageUrl('https://res.cloudinary.com/demo/image/upload/sample.jpg'), isNull);
      expect(Validator.validateImageUrl('http://example.com/item.png'), isNull);
    });
  });

  group('3. ImageService & CloudinaryConfig - Kiểm thử cấu hình', () {
    test('CloudinaryConfig phải được cấu hình đầy đủ và chính xác', () {
      expect(CloudinaryConfig.isConfigured, isTrue);
      expect(CloudinaryConfig.cloudName, equals('dkmllunui'));
      expect(CloudinaryConfig.uploadPreset, equals('techstore_preset'));
      expect(
        CloudinaryConfig.uploadUrl,
        equals('https://api.cloudinary.com/v1_1/dkmllunui/image/upload'),
      );
    });

    test('ImageService.isValidImageUrl nhận diện đúng URL', () {
      final imageService = ImageService();
      expect(imageService.isValidImageUrl('https://res.cloudinary.com/image.png'), isTrue);
      expect(imageService.isValidImageUrl('http://example.com/test.jpg'), isTrue);
      expect(imageService.isValidImageUrl('invalid_url'), isFalse);
      expect(imageService.isValidImageUrl(''), isFalse);
      expect(imageService.isValidImageUrl(null), isFalse);
    });
  });
}
