import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:techstore/models/product_model.dart';
import 'package:techstore/providers/product_provider.dart';
import 'package:techstore/services/product_service.dart';
import 'package:techstore/views/products/product_list_screen.dart';
import 'package:techstore/views/widgets/product_card.dart';

class FakeProductService extends ProductService {
  @override
  Stream<List<ProductModel>> getProductsStream() {
    return Stream.value([
      const ProductModel(
        id: '1',
        name: 'Tai nghe Bluetooth AirPods Pro',
        price: 350000,
        soluong: 15,
        image: '',
      ),
      const ProductModel(
        id: '2',
        name: 'Pin sạc Xiaomi 20000mAh',
        price: 420000,
        soluong: 8,
        image: '',
      ),
    ]);
  }
}

void main() {
  testWidgets(
    'ProductCard hiển thị chính xác đầy đủ 4 trường dữ liệu theo quy định',
    (WidgetTester tester) async {
      const product = ProductModel(
        id: 'test_id_101',
        name: 'Tai nghe Bluetooth True Wireless',
        price: 350000,
        soluong: 15,
        image: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProductCard(product: product)),
        ),
      );

      expect(find.text('Tai nghe Bluetooth True Wireless'), findsOneWidget);
      expect(find.textContaining('350.000'), findsOneWidget);
      expect(find.textContaining('15'), findsOneWidget);
      expect(find.byType(ProductCard), findsOneWidget);
    },
  );

  testWidgets(
    'ProductListScreen phải lọc danh sách theo từ khóa tìm kiếm khi người dùng nhập',
    (WidgetTester tester) async {
      final provider = ProductProvider(
        productsStream: Stream.value([
          const ProductModel(
            id: '1',
            name: 'Tai nghe Bluetooth AirPods Pro',
            price: 350000,
            soluong: 15,
            image: '',
          ),
          const ProductModel(
            id: '2',
            name: 'Pin sạc Xiaomi 20000mAh',
            price: 420000,
            soluong: 8,
            image: '',
          ),
        ]),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: provider),
          ],
          child: const MaterialApp(home: ProductListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tai nghe Bluetooth AirPods Pro'), findsOneWidget);
      expect(find.text('Pin sạc Xiaomi 20000mAh'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'air');
      await tester.pump();

      expect(provider.searchQuery, 'air');
      expect(find.text('Tai nghe Bluetooth AirPods Pro'), findsOneWidget);
      expect(find.text('Pin sạc Xiaomi 20000mAh'), findsNothing);
    },
  );
}
