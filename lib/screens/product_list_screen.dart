import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductController controller = Get.put(ProductController());
  final ThemeController themeController = Get.put(ThemeController());
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Explorer'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(themeController.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                onPressed: themeController.toggleTheme,
                tooltip: 'Toggle theme',
              )),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          controller.clearSearch();
                        },
                      )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.state.value) {
                case ViewState.loading:
                  return const LoadingView();
                case ViewState.error:
                  return ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchInitialProducts,
                  );
                case ViewState.empty:
                  return RefreshIndicator(
                    onRefresh: controller.refreshProducts,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        EmptyView(),
                      ],
                    ),
                  );
                case ViewState.loaded:
                case ViewState.loadingMore:
                  return RefreshIndicator(
                    onRefresh: controller.refreshProducts,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.products.length +
                          (controller.state.value == ViewState.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.products.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        final product = controller.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Get.to(
                              () => ProductDetailScreen(productId: product.id)),
                        );
                      },
                    ),
                  );
              }
            }),
          ),
        ],
      ),
    );
  }
}
