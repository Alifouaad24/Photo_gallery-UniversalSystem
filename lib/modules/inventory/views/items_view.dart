import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/models/ItemResponseModel.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  static const _primary = Color(0xFF0F2A47);
  static const _accent = Color(0xFFF5A524);
  static const _bg = Color(0xFFF7F8FB);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessId = Get.arguments['businessId'];
      Get.find<InventoryController>().getItems(businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: GetBuilder<InventoryController>(
          builder: (controller) {
            if (controller.isLoading) {
              return _buildLoadingState();
            }

            if (controller.errorMessage != null) {
              return _buildErrorState(controller.errorMessage!);
            }

            if (controller.items.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: _primary,
              onRefresh: () async {
                final businessId = Get.arguments['businessId'];
                await controller.getItems(businessId);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(controller.items.length)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.74,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = controller.items[index];
                          return _ItemCard(item: item);
                        },
                        childCount: controller.items.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory Items',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count item${count == 1 ? '' : 's'} in stock',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: _primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: _primary),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Items you add will show up here',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemResponseModel item;

  const _ItemCard({required this.item});

  static const _primary = Color(0xFF0F2A47);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildUpcBadge(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.upc?.isNotEmpty == true ? item.upc! : 'No UPC',
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 12, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = _extractImageUrl();

    if (imageUrl == null) {
      return _emptyImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _emptyImage(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: _primary.withOpacity(0.6),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  String? _extractImageUrl() {
    if (item.images == null) return null;
    if (item.images is! List || (item.images as List).isEmpty) return null;

    final firstImage = (item.images as List).first;

    if (firstImage is Map) {
      final url = firstImage['imageUrl']?.toString();
      if (url != null && url.isNotEmpty) return url;
    }

    return null;
  }

  Widget _emptyImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade100, Colors.grey.shade200],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 38,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}