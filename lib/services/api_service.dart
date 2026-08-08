import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'api_exception.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<ProductResponse> fetchProducts({int limit = 10, int skip = 0}) async {
    final uri = Uri.parse('$baseUrl/products?limit=$limit&skip=$skip');
    return _getProductResponse(uri);
  }

  Future<ProductResponse> searchProducts(String query,
      {int limit = 10, int skip = 0}) async {
    final uri = Uri.parse(
        '$baseUrl/products/search?q=${Uri.encodeQueryComponent(query)}&limit=$limit&skip=$skip');
    return _getProductResponse(uri);
  }

  Future<Product> fetchProductDetail(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      _checkStatusCode(response.statusCode);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Product.fromJson(data);
    } on SocketException {
      throw NoInternetException();
    } on FormatException {
      throw ServerException('Invalid response format from server.');
    }
  }

  Future<ProductResponse> _getProductResponse(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      _checkStatusCode(response.statusCode);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ProductResponse.fromJson(data);
    } on SocketException {
      throw NoInternetException();
    } on FormatException {
      throw ServerException('Invalid response format from server.');
    }
  }

  void _checkStatusCode(int code) {
    if (code == 404) {
      throw NotFoundException();
    } else if (code >= 500) {
      throw ServerException();
    } else if (code < 200 || code >= 300) {
      throw ServerException('Unexpected error (code: $code).');
    }
  }
}
