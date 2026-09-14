class InventoryModel {
  final int? inventoryId;
  final String? productName;
  final String? weight;
  final double? height;
  final double? depth;
  final String? upc;
  final String? sku;
  final String? model;
  final String? notes;
  final String? sitePrice;
  final int? folderImages;
  final int? qty;
  final String? internetId;
  final String? productDescription;

  final PlatformModel? platform;
  final int? platformId;

  final CategoryModel? category;
  final int? categoryId;

  final ItemModel? item;
  final int? itemId;

  final ItemConditionModel? itemCondition;
  final int? itemConditionId;

  final int? businessId;

  final String? ebayInvID;
  final String? ebayOfferID;
  final String? ebayListingId;

  final String? status;

  final bool? visible;
  final bool? isSold;
  final bool? isPublishedOnMarketPlace;
  final bool? isProccessedInInventory;
  final bool? notFound;

  final String? marketPlaceOfferUrl;

  bool get isBiometricComplete {
    final categoryOk = (item?.category?.name ?? '').trim().isNotEmpty;

    final descriptionOk = (item?.description ?? '').trim().isNotEmpty;

    final detailsOk = (item?.itemDetails ?? '').trim().isNotEmpty;

    final priceOk = item?.basePrice != null;

    return categoryOk && descriptionOk && detailsOk && priceOk;
  }

  InventoryModel copyWith({int? qty}) {
    return InventoryModel(
      inventoryId: inventoryId,
      productName: productName,
      item: item,
      qty: qty ?? this.qty,
    );
  }

  InventoryModel({
    this.inventoryId,
    this.productName,
    this.weight,
    this.height,
    this.depth,
    this.upc,
    this.sku,
    this.model,
    this.notes,
    this.sitePrice,
    this.folderImages,
    this.qty,
    this.internetId,
    this.productDescription,
    this.platform,
    this.platformId,
    this.category,
    this.categoryId,
    this.item,
    this.itemId,
    this.itemCondition,
    this.itemConditionId,
    this.businessId,
    this.ebayInvID,
    this.ebayOfferID,
    this.ebayListingId,
    this.status,
    this.visible,
    this.isSold,
    this.isPublishedOnMarketPlace,
    this.isProccessedInInventory,
    this.notFound,
    this.marketPlaceOfferUrl,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json['inventory_id'],
      productName: json['product_name'],
      weight: json['weight'],
      height: (json['height'] as num?)?.toDouble(),
      depth: (json['depth'] as num?)?.toDouble(),
      upc: json['upc'],
      sku: json['sku'],
      model: json['model'],
      notes: json['notes'],
      sitePrice: json['sitePrice'],
      folderImages: json['folderImages'],
      qty: json['qtyPublished'],
      internetId: json['internetId'],
      productDescription: json['product_description'],
      platform: json['platform'] == null
          ? null
          : PlatformModel.fromJson(json['platform']),
      platformId: json['platform_id'],
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category']),
      categoryId: json['category_id'],
      item: json['item'] == null ? null : ItemModel.fromJson(json['item']),
      itemId: json['itemId'],
      itemCondition: json['itemCondition'] == null
          ? null
          : ItemConditionModel.fromJson(json['itemCondition']),
      itemConditionId: json['itemConditionId'],
      businessId: json['business_id'],
      ebayInvID: json['ebayInvID'],
      ebayOfferID: json['ebayOfferID'],
      ebayListingId: json['ebayListingId'],
      status: json['status'],
      visible: json['visible'],
      isSold: json['isSold'],
      isPublishedOnMarketPlace: json['isPublishedOnMarketPlace'],
      isProccessedInInventory: json['isProccessedInInventory'],
      notFound: json['notFound'],
      marketPlaceOfferUrl: json['marketPlaceOfferUrl'],
    );
  }
}

class PlatformModel {
  final int? platformId;
  final String? description;
  final String? productUrl;

  PlatformModel({this.platformId, this.description, this.productUrl});

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      platformId: json['platform_id'],
      description: json['description'],
      productUrl: json['productUrl'],
    );
  }
}

class CategoryModel {
  final int? categoryId;
  final String? name;
  final String? ebayCategoryId;

  CategoryModel({this.categoryId, this.name, this.ebayCategoryId});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'],
      name: json['name'],
      ebayCategoryId: json['ebayCategoryId'],
    );
  }
}

class ItemConditionModel {
  final int? itemConditionId;
  final String? description;
  final int? ebayConditionId;

  ItemConditionModel({
    this.itemConditionId,
    this.description,
    this.ebayConditionId,
  });

  factory ItemConditionModel.fromJson(Map<String, dynamic> json) {
    return ItemConditionModel(
      itemConditionId: json['itemConditionId'],
      description: json['description'],
      ebayConditionId: json['ebayConditionId'],
    );
  }
}

class ItemImageModel {
  final int? itemImageId;
  final String? imageUrl;
  final bool? isMain;
  final bool? isPublishedOnEbay;

  ItemImageModel({
    this.itemImageId,
    this.imageUrl,
    this.isMain,
    this.isPublishedOnEbay,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      itemImageId: json['itemImageId'],
      imageUrl: json['imageUrl'],
      isMain: json['isMain'],
      isPublishedOnEbay: json['isPublishedOnEbay'],
    );
  }
}

class ItemModel {
  final int? itemId;

  final String? itemDescription;
  final String? itemDetails;

  final String? sku;
  final String? internetId;
  final String? upc;
  final String? shortCode;
  final String? model;

  // Platform
  final int? platformId;
  final PlatformModel? platform;

  // Dimensions
  final double? height;
  final double? width;
  final double? length;

  // Unit






  // General
  final String? description;
  final double? weight;
  final String? internet;



  // Category
  final int? categoryId;
  final CategoryModel? category;

  // Price / Currency
  final double? basePrice;


  // Status
  final bool? isActive;
  final bool? isScraped;
  final bool? isComplated;
  final bool? canScrape;

  // Images / Business
  final List<ItemImageModel> images;

  final String? insertBy;

  // Car information
  final String? vinNumber;


  // Customer
  final int? globalCustomerId;

  ItemModel({
    this.itemId,
    this.itemDescription,
    this.itemDetails,
    this.sku,
    this.internetId,
    this.upc,
    this.shortCode,
    this.model,
    this.platformId,
    this.platform,
    this.height,
    this.width,
    this.length,

    this.description,
    this.weight,
    this.internet,
    this.categoryId,
    this.category,
    this.basePrice,
    this.isActive,
    this.isScraped,
    this.isComplated,
    this.canScrape,
    required this.images,
    this.insertBy,
    this.vinNumber,

    this.globalCustomerId,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: json['itemId'],

      itemDescription: json['itemDescription'],
      itemDetails: json['itemDetails'],

      sku: json['sku'],
      internetId: json['internetId'],
      upc: json['upc'],
      shortCode: json['shortCode'],
      model: json['model'],

      // Platform
      platformId: json['platformId'],
      platform: json['platform'] != null
          ? PlatformModel.fromJson(Map<String, dynamic>.from(json['platform']))
          : null,

      // Dimensions
      height: (json['height'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),



      // General
      description: json['description'],
      weight: (json['weight'] as num?)?.toDouble(),
      internet: json['internet'],



      // Category
      categoryId: json['categoryId'],
      category: json['category'] != null
          ? CategoryModel.fromJson(Map<String, dynamic>.from(json['category']))
          : null,

      // Price / Currency
      basePrice: (json['basePrice'] as num?)?.toDouble(),

      // Status
      isActive: json['isActive'],
      isScraped: json['isScraped'],
      isComplated: json['isComplated'],
      canScrape: json['canScrape'],

      // Images
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ItemImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      // Business Items

      insertBy: json['insertBy'],

      // Car
      vinNumber: json['vinNumber'],


      // Customer
      // Customer نفسه [JsonIgnore] لذلك لن يأتي في JSON
      globalCustomerId: json['globalCustomerId'],
    );
  }
}
