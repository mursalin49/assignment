import 'package:flutter_test/flutter_test.dart';
import 'package:product_explorer/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a full product JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'iPhone 9',
        'description': 'A great phone',
        'price': 549,
        'discountPercentage': 12.96,
        'rating': 4.69,
        'stock': 94,
        'brand': 'Apple',
        'category': 'smartphones',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'iPhone 9');
      expect(product.price, 549.0);
      expect(product.brand, 'Apple');
      expect(product.images.length, 2);
    });

    test('handles missing optional fields gracefully', () {
      final json = {'id': 2, 'title': 'No Image Product'};
      final product = Product.fromJson(json);

      expect(product.id, 2);
      expect(product.images, isEmpty);
      expect(product.price, 0.0);
    });
  });

  group('discountedPrice', () {
    test('calculates discounted price correctly', () {
      final product = Product(
        id: 1,
        title: 'Test',
        description: '',
        price: 100,
        discountPercentage: 10,
        rating: 4.5,
        stock: 10,
        brand: 'Test',
        category: 'test',
        thumbnail: '',
        images: const [],
      );

      expect(product.discountedPrice, 90.0);
    });

    test('returns full price when no discount', () {
      final product = Product(
        id: 1,
        title: 'Test',
        description: '',
        price: 100,
        discountPercentage: 0,
        rating: 4.5,
        stock: 10,
        brand: 'Test',
        category: 'test',
        thumbnail: '',
        images: const [],
      );

      expect(product.discountedPrice, 100.0);
    });
  });

  group('ProductResponse.fromJson', () {
    test('parses list of products with pagination fields', () {
      final json = {
        'products': [
          {'id': 1, 'title': 'A'},
          {'id': 2, 'title': 'B'},
        ],
        'total': 100,
        'skip': 0,
        'limit': 10,
      };

      final response = ProductResponse.fromJson(json);

      expect(response.products.length, 2);
      expect(response.total, 100);
      expect(response.limit, 10);
    });
  });
}
