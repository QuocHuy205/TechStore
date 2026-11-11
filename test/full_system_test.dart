import 'package:flutter_test/flutter_test.dart';
import 'package:techstore/models/product_model.dart';
import 'package:techstore/core/utils/validator.dart';
import 'package:techstore/core/constants/cloudinary_config.dart';
import 'package:techstore/services/image_service.dart';

void main() {
  group('I. AUTHENTICATION & VALIDATION TEST', () {
    test('TC-AUTH-01: Kiểm tra email admin hợp lệ', () {
      expect(Validator.validateEmail('admin@techstore.com'), isNull);
      expect(Validator.validateEmail('manager@techstore.vn'), isNull);
    });

    test('TC-AUTH-02: Kiểm tra email sai định dạng hoặc rỗng', () {
      expect(Validator.validateEmail(''), isNotNull);
      expect(Validator.validateEmail(null), isNotNull);
      expect(Validator.validateEmail('admin'), isNotNull);
      expect(Validator.validateEmail('admin@'), isNotNull);
      expect(Validator.validateEmail('admin@techstore'), isNotNull);
    });

    test('TC-AUTH-03: Kiểm tra mật khẩu hợp lệ (tối thiểu 6 ký tự)', () {
      expect(Validator.validatePassword('Admin@2026'), isNull);
      expect(Validator.validatePassword('123456'), isNull);
    });

    test(
      'TC-AUTH-04: Kiểm tra mật khẩu không hợp lệ (< 6 ký tự hoặc rỗng)',
      () {
        expect(Validator.validatePassword(''), isNotNull);
        expect(Validator.validatePassword(null), isNotNull);
        expect(Validator.validatePassword('12345'), isNotNull);
      },
    );
  });

  group('II. VALIDATION DỮ LIỆU ĐẦU VÀO FORM SẢN PHẨM', () {
    test('TC-VAL-01: Tên sản phẩm để trống hoặc chỉ có khoảng trắng', () {
      expect(Validator.validateName(''), isNotNull);
      expect(Validator.validateName('   '), isNotNull);
      expect(Validator.validateName(null), isNotNull);
    });

    test('TC-VAL-02: Tên sản phẩm quá ngắn (< 2 ký tự)', () {
      expect(Validator.validateName('A'), isNotNull);
    });

    test('TC-VAL-03: Tên sản phẩm hợp lệ', () {
      expect(Validator.validateName('Tai nghe Bluetooth JBL'), isNull);
      expect(Validator.validateName('Ốp lưng iPhone 15 Pro Max'), isNull);
    });

    test('TC-VAL-04: Giá sản phẩm âm hoặc bằng 0', () {
      expect(Validator.validatePrice('-100000'), isNotNull);
      expect(Validator.validatePrice('-1'), isNotNull);
      expect(Validator.validatePrice('0'), isNotNull);
    });

    test('TC-VAL-05: Giá sản phẩm sai định dạng (chứa chữ cái, ký tự lạ)', () {
      expect(Validator.validatePrice('abc'), isNotNull);
      expect(Validator.validatePrice('150k'), isNotNull);
      expect(Validator.validatePrice(''), isNotNull);
      expect(Validator.validatePrice(null), isNotNull);
    });

    test(
      'TC-VAL-06: Giá sản phẩm hợp lệ (hỗ trợ cả số nguyên và định dạng có dấu chấm)',
      () {
        expect(Validator.validatePrice('350000'), isNull);
        expect(Validator.validatePrice('1.200.000'), isNull);
        expect(Validator.validatePrice('85000'), isNull);
      },
    );

    test('TC-VAL-07: Số lượng sản phẩm âm', () {
      expect(Validator.validateSoluong('-1'), isNotNull);
      expect(Validator.validateSoluong('-50'), isNotNull);
    });

    test('TC-VAL-08: Số lượng sản phẩm là số thập phân hoặc chữ', () {
      expect(Validator.validateSoluong('15.5'), isNotNull);
      expect(Validator.validateSoluong('hai'), isNotNull);
      expect(Validator.validateSoluong(''), isNotNull);
      expect(Validator.validateSoluong(null), isNotNull);
    });

    test('TC-VAL-09: Số lượng sản phẩm hợp lệ (số nguyên >= 0)', () {
      expect(Validator.validateSoluong('0'), isNull); // 0 là hết hàng - hợp lệ
      expect(Validator.validateSoluong('15'), isNull);
      expect(Validator.validateSoluong('100'), isNull);
    });

    test('TC-VAL-10: Chưa chọn ảnh hoặc URL ảnh rỗng', () {
      expect(Validator.validateImageUrl(''), isNotNull);
      expect(Validator.validateImageUrl(null), isNotNull);
      expect(Validator.validateImageUrl('   '), isNotNull);
    });

    test('TC-VAL-11: URL ảnh sai định dạng', () {
      expect(Validator.validateImageUrl('file://path/to/image.jpg'), isNotNull);
      expect(Validator.validateImageUrl('ftp://server/image.png'), isNotNull);
      expect(Validator.validateImageUrl('not_a_valid_url'), isNotNull);
      expect(Validator.validateImageUrl(''), isNotNull);
      expect(Validator.validateImageUrl(null), isNotNull);
    });

    test('TC-VAL-12: URL ảnh hợp lệ', () {
      expect(
        Validator.validateImageUrl(
          'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        ),
        isNull,
      );
      expect(
        Validator.validateImageUrl(
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
        ),
        isNull,
      );
      expect(
        Validator.validateImageUrl('https://example.com/sample.jpg'),
        isNull,
      );
    });
  });

  group('III. DATABASE & MODEL INTEGRITY TEST (Đúng 4 trường duy nhất)', () {
    test('TC-DB-01: ProductModel.toMap chỉ trả về CHÍNH XÁC 4 trường', () {
      const product = ProductModel(
        id: 'auto_id_12345',
        name: 'Cáp sạc Type-C 60W',
        price: 85000,
        soluong: 100,
        image: 'https://res.cloudinary.com/dkmllunui/image/upload/cable.jpg',
      );

      final map = product.toMap();

      // Phải có đúng 4 trường
      expect(map.length, equals(4));
      expect(map.keys, containsAll(['name', 'price', 'soluong', 'image']));
    });

    test('TC-DB-02: Document ID KHÔNG BAO GIỜ được đưa vào toMap()', () {
      const product = ProductModel(
        id: 'firestore_doc_id_999',
        name: 'Ốp lưng Silicon',
        price: 120000,
        soluong: 50,
        image: 'https://res.cloudinary.com/demo.jpg',
      );

      final map = product.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('docId'), isFalse);
      expect(map.containsKey('documentId'), isFalse);
    });

    test(
      'TC-DB-03: Tuyệt đối KHÔNG có trường thừa (createdAt, updatedAt, isDeleted, archive)',
      () {
        const product = ProductModel(
          id: '1',
          name: 'Kính cường lực 9D',
          price: 60000,
          soluong: 80,
          image: 'https://res.cloudinary.com/glass.jpg',
        );

        final map = product.toMap();

        expect(map.containsKey('createdAt'), isFalse);
        expect(map.containsKey('updatedAt'), isFalse);
        expect(map.containsKey('isDeleted'), isFalse);
        expect(map.containsKey('archive'), isFalse);
        expect(map.containsKey('deletedAt'), isFalse);
      },
    );

    test('TC-DB-04: Kiểm tra kiểu dữ liệu chuẩn xác của 4 trường', () {
      const product = ProductModel(
        id: '2',
        name: 'Loa Bluetooth Mini',
        price: 520000,
        soluong: 12,
        image: 'https://res.cloudinary.com/speaker.jpg',
      );

      final map = product.toMap();

      expect(map['name'], isA<String>());
      expect(map['price'], isA<num>());
      expect(map['soluong'], isA<int>());
      expect(map['image'], isA<String>());
    });

    test(
      'TC-DB-05: ProductModel.fromMap khôi phục đầy đủ dữ liệu kèm Document ID',
      () {
        final firestoreData = {
          'name': 'Pin dự phòng 10.000mAh',
          'price': 380000,
          'soluong': 15,
          'image': 'https://res.cloudinary.com/powerbank.jpg',
        };

        final product = ProductModel.fromMap(firestoreData, 'doc_pin_10000');

        expect(product.id, equals('doc_pin_10000'));
        expect(product.name, equals('Pin dự phòng 10.000mAh'));
        expect(product.price, equals(380000));
        expect(product.soluong, equals(15));
        expect(
          product.image,
          equals('https://res.cloudinary.com/powerbank.jpg'),
        );
      },
    );

    test(
      'TC-DB-06: ProductModel.copyWith cập nhật đúng từng trường riêng lẻ',
      () {
        const original = ProductModel(
          id: 'prod_01',
          name: 'Củ sạc nhanh 20W',
          price: 150000,
          soluong: 20,
          image: 'https://res.cloudinary.com/old_charger.jpg',
        );

        // Sửa tên
        final editedName = original.copyWith(name: 'Củ sạc nhanh GaN 30W');
        expect(editedName.name, equals('Củ sạc nhanh GaN 30W'));
        expect(editedName.price, equals(150000));

        // Sửa giá
        final editedPrice = original.copyWith(price: 250000);
        expect(editedPrice.price, equals(250000));
        expect(editedPrice.name, equals('Củ sạc nhanh 20W'));

        // Sửa số lượng
        final editedQty = original.copyWith(soluong: 35);
        expect(editedQty.soluong, equals(35));

        // Sửa ảnh
        final editedImg = original.copyWith(
          image: 'https://res.cloudinary.com/new_charger.jpg',
        );
        expect(
          editedImg.image,
          equals('https://res.cloudinary.com/new_charger.jpg'),
        );
      },
    );
  });

  group('IV. IMAGE & CLOUDINARY CONFIGURATION TEST', () {
    test('TC-IMG-01: Kiểm tra cấu hình Cloudinary hợp lệ', () {
      expect(CloudinaryConfig.isConfigured, isTrue);
      expect(CloudinaryConfig.cloudName, equals('dkmllunui'));
      expect(CloudinaryConfig.uploadPreset, equals('techstore_preset'));
    });

    test(
      'TC-IMG-02: Kiểm tra Endpoint Upload của Cloudinary đúng cấu trúc chuẩn REST API',
      () {
        expect(
          CloudinaryConfig.uploadUrl,
          equals('https://api.cloudinary.com/v1_1/dkmllunui/image/upload'),
        );
      },
    );

    test(
      'TC-IMG-03: ImageService.isValidImageUrl nhận diện đúng URL ảnh hợp lệ',
      () {
        final service = ImageService();
        expect(
          service.isValidImageUrl(
            'https://res.cloudinary.com/dkmllunui/image/upload/sample.jpg',
          ),
          isTrue,
        );
        expect(service.isValidImageUrl('http://example.com/photo.png'), isTrue);
        expect(service.isValidImageUrl('invalid-url'), isFalse);
        expect(service.isValidImageUrl(''), isFalse);
        expect(service.isValidImageUrl(null), isFalse);
      },
    );
  });
}
