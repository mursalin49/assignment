import 'dart:async';
import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

enum ViewState { loading, loaded, error, empty, loadingMore }

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<Product> products = <Product>[].obs;
  final Rx<ViewState> state = ViewState.loading.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  int _skip = 0;
  final int _limit = 10;
  int _total = 0;
  Timer? _debounce;

  bool get hasMore => products.length < _total;

  @override
  void onInit() {
    super.onInit();
    fetchInitialProducts();
  }

  Future<void> fetchInitialProducts() async {
    _skip = 0;
    state.value = ViewState.loading;
    try {
      final response = await _apiService.fetchProducts(limit: _limit, skip: _skip);
      products.assignAll(response.products);
      _total = response.total;
      _skip = response.products.length;
      state.value = products.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (e) {
      errorMessage.value = e is ApiException ? e.message : 'Unexpected error occurred.';
      state.value = ViewState.error;
    }
  }

  Future<void> refreshProducts() async {
    _skip = 0;
    try {
      final response = isSearching.value && searchQuery.value.isNotEmpty
          ? await _apiService.searchProducts(searchQuery.value, limit: _limit, skip: 0)
          : await _apiService.fetchProducts(limit: _limit, skip: 0);
      products.assignAll(response.products);
      _total = response.total;
      _skip = response.products.length;
      state.value = products.isEmpty ? ViewState.empty : ViewState.loaded;
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = e is ApiException ? e.message : 'Unexpected error occurred.';
      if (products.isEmpty) state.value = ViewState.error;
      else Get.snackbar('Refresh failed', errorMessage.value);
    }
  }

  Future<void> loadMore() async {
    if (state.value == ViewState.loadingMore || !hasMore) return;
    state.value = ViewState.loadingMore;
    try {
      final response = isSearching.value && searchQuery.value.isNotEmpty
          ? await _apiService.searchProducts(searchQuery.value, limit: _limit, skip: _skip)
          : await _apiService.fetchProducts(limit: _limit, skip: _skip);
      products.addAll(response.products);
      _skip += response.products.length;
      state.value = ViewState.loaded;
    } catch (e) {
      state.value = ViewState.loaded;
      Get.snackbar('Could not load more', e is ApiException ? e.message : 'Unexpected error.');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _skip = 0;
    if (query.trim().isEmpty) {
      isSearching.value = false;
      await fetchInitialProducts();
      return;
    }
    isSearching.value = true;
    state.value = ViewState.loading;
    try {
      final response = await _apiService.searchProducts(query, limit: _limit, skip: 0);
      products.assignAll(response.products);
      _total = response.total;
      _skip = response.products.length;
      state.value = products.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (e) {
      errorMessage.value = e is ApiException ? e.message : 'Unexpected error occurred.';
      state.value = ViewState.error;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    fetchInitialProducts();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
