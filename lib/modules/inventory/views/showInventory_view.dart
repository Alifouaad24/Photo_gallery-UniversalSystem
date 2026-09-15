import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/inventoryModel.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';
import 'package:photo_gallery/modules/inventory/views/BarcodeScannerView.dart';
import 'package:photo_gallery/modules/inventory/views/EditInventoryResult.dart';

/// -------- Design tokens --------
class _Palette {
  static const bg = Color(0xFFF4F6F9);
  static const card = Colors.white;
  static const border = Color(0xFFEDEFF3);
  static const ink = Color(0xFF1B1F27);
  static const inkMuted = Color(0xFF6B7280);
  static const primary = Color(0xFF3457D5);
  static const primarySoft = Color(0xFFEFF2FF);
  static const success = Color(0xFF1CA97C);
  static const successSoft = Color(0xFFE7F8F2);
  static const danger = Color(0xFFE0473A);
  static const dangerSoft = Color(0xFFFCEBEA);
}

class ShowinventoryView extends StatelessWidget {
  ShowinventoryView({super.key});
  final TextEditingController searchController = TextEditingController();

  Future<void> _openCameraForNewItem() async {
    var cameraController = Get.find<CameraGetController>();
    cameraController.AddToItemAndInventory = true;
    cameraController.ItemUpc = '';
    cameraController.update();

    final changed = await Get.toNamed(Routes.cameraSession);
    if (changed == true) {
      Get.toNamed(Routes.gallery);
    }
  }

  /// ترتيب بسيط: العناصر "الغير منجزة" (isBiometricComplete != true)
  /// دايمًا فوق، والمنجزة تحت.
  List<InventoryModel> _sorted(List<InventoryModel> list) {
    final sortedList = [...list];
    sortedList.sort((a, b) {
      final aDone = a.isBiometricComplete == true;
      final bDone = b.isBiometricComplete == true;
      if (aDone == bDone) return 0;
      return aDone ? 1 : -1; // الغير منجز (false) يطلع الأول
    });
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      appBar: AppBar(
        backgroundColor: _Palette.card,
        elevation: 0,
        foregroundColor: _Palette.ink,
        title: const Text(
          "Inventory",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: GetBuilder<InventoryController>(
        builder: (controller) {
          if (controller.isLoadingInv) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (controller.inventoryList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No Inventory Found",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 14),
                  _cameraButton(onTap: _openCameraForNewItem),
                ],
              ),
            );
          }

          final items = _sorted(controller.filteredInventory);

          return Column(
            children: [
              /// -------- بحث + مسح باركود --------
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: controller.searchInventory,
                        decoration: InputDecoration(
                          hintText: "Search UPC, Model, Product...",
                          hintStyle: TextStyle(
                            color: _Palette.inkMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _Palette.inkMuted,
                          ),
                          filled: true,
                          fillColor: _Palette.card,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: _Palette.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: _Palette.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: _Palette.primary,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final code = await Get.to<String>(
                          () => const BarcodeScannerView(),
                        );
                        if (code != null) {
                          searchController.text = code;
                          controller.searchInventory(code);
                        }
                      },
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: _Palette.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _Palette.primary.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// -------- القائمة --------
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "No Results Found",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 14),
                            _cameraButton(onTap: _openCameraForNewItem),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        itemCount: items.length,
                        itemBuilder: (_, index) =>
                            _SimpleInventoryCard(item: items[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _cameraButton({required VoidCallback onTap}) {
  return OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.camera_alt_rounded),
    label: const Text("Camera"),
    style: OutlinedButton.styleFrom(
      foregroundColor: _Palette.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      side: const BorderSide(color: _Palette.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// -------- كارت مبسط: صورة كبيرة + 3 أيقونات حالة + الكمية --------
class _SimpleInventoryCard extends StatelessWidget {
  final InventoryModel item;

  const _SimpleInventoryCard({required this.item});

  void _openBioDialog(BuildContext context) {
    final controller = Get.find<InventoryController>();
    showEditInventoryDialog(
      item,
      categories: controller.categories,
      conditions: controller.conditions,
      onSave: (result) async {
        await controller.updateInventoryItem(item.inventoryId!, result);
      },
    );
  }

  /// بيفتح معرض صور المنتج كامل الشاشة: تقليب بين الصور، زوم بإصبعين،
  /// وتدوير بإصبعين (enableRotation جوه PhotoView).
  void _openImageViewer(BuildContext context) {
    final urls = (item.item?.images ?? [])
        .map((img) => img.imageUrl ?? "")
        .where((u) => u.isNotEmpty)
        .toList();

    if (urls.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageGalleryViewer(
          imageUrls: urls,
          heroTagPrefix: 'inv-image-${item.inventoryId}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = item.item?.images.isNotEmpty ?? false;
    final imageUrl = hasImage ? item.item!.images.first.imageUrl : null;

    final hasUpc = (item.upc ?? item.item?.upc ?? "").isNotEmpty;
    final isBio = item.isBiometricComplete == true;

    // ⚠️ افتراض: اسم الحقل isScraped مش متأكد منه 100% — عدّله لو مختلف
    // عندك في الموديل الحقيقي.
    final isScraped = item.item?.isScraped == true;

    final qty = item.qty ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// -------- صورة كبيرة (بتفتح المعرض الكامل عند الضغط) --------
          GestureDetector(
            onTap: hasImage ? () => _openImageViewer(context) : null,
            child: AspectRatio(
              aspectRatio: 1.5,
              child: hasImage
                  ? Hero(
                      tag: 'inv-image-${item.inventoryId}',
                      child: Image.network(
                        imageUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _Palette.bg,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: _Palette.inkMuted,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: _Palette.bg,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: _Palette.inkMuted,
                      ),
                    ),
            ),
          ),

          /// -------- 3 أيقونات حالة + الكمية --------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _StatusIcon(
                  icon: Icons.qr_code_rounded,
                  label: "UPC",
                  done: hasUpc,
                ),
                const SizedBox(width: 8),
                _StatusIcon(
                  icon: Icons.fingerprint_rounded,
                  label: "BIO",
                  done: isBio,
                  // لو ناقص، الضغط بيفتح ديالوج إكمال البيانات وحفظها
                  onTap: isBio ? null : () => _openBioDialog(context),
                ),
                const SizedBox(width: 8),
                _StatusIcon(
                  icon: Icons.travel_explore_rounded,
                  label: "Scrape",
                  done: isScraped,
                ),
                const Spacer(),
                _QtyBadge(qty: qty),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// -------- أيقونة حالة (منجز/غير منجز) — قابلة للضغط اختياريًا --------
class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;
  final VoidCallback? onTap;

  const _StatusIcon({
    required this.icon,
    required this.label,
    required this.done,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? _Palette.success : _Palette.danger;
    final bg = done ? _Palette.successSoft : _Palette.dangerSoft;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: (!done && onTap != null)
              ? Border.all(color: color.withOpacity(0.4))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------- شارة الكمية --------
class _QtyBadge extends StatelessWidget {
  final int qty;

  const _QtyBadge({required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _Palette.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "QTY",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _Palette.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "$qty",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _Palette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// -------- معرض صور كامل الشاشة: تقليب بين الصور + زوم وتدوير بإصبعين --------
class _ImageGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTagPrefix;

  const _ImageGalleryViewer({
    required this.imageUrls,
    this.initialIndex = 0,
    required this.heroTagPrefix,
  });

  @override
  State<_ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<_ImageGalleryViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          "${_currentIndex + 1} / ${widget.imageUrls.length}",
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            initialScale: PhotoViewComputedScale.contained,
            // بيفعّل التدوير بإصبعين (pinch + twist) على كل صورة.
            heroAttributes: index == widget.initialIndex
                ? PhotoViewHeroAttributes(tag: widget.heroTagPrefix)
                : null,
          );
        },
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
