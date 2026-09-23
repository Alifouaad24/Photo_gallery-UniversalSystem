class ItemResponseModel {
  final int itemId;

  final String? itemDescription;
  final String? itemDetails;
  final String? sku;
  final String? internetId;
  final String? upc;
  final String? shortCode;
  final String? model;

  final int? platformId;
  final dynamic platform;

  final double? height;
  final double? width;
  final double? length;

  final int? unitId;
  final dynamic unit;
  final double? unitValue;

  final int? colorId;
  final dynamic color;

  final int? carBrandId;
  final dynamic carBrand;

  final String? description;
  final double? weight;
  final String? internet;

  final int? sizeId;
  final dynamic size;

  final int? categoryId;
  final dynamic category;

  final double? basePrice;

  final int? currencyId;
  final dynamic currency;

  final bool? isActive;
  final bool? isScraped;
  final bool? isComplated;
  final bool? canScrape;

  final dynamic images;
  final dynamic businessItems;

  final int? insertBy;

  final String? vinNumber;

  final int? carYearId;
  final dynamic carYear;

  final int? carModelId;
  final dynamic carModel;

  final int? globalCustomerId;

  final bool isInStock;

  ItemResponseModel({
    required this.itemId,
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
    this.unitId,
    this.unit,
    this.unitValue,
    this.colorId,
    this.color,
    this.carBrandId,
    this.carBrand,
    this.description,
    this.weight,
    this.internet,
    this.sizeId,
    this.size,
    this.categoryId,
    this.category,
    this.basePrice,
    this.currencyId,
    this.currency,
    this.isActive,
    this.isScraped,
    this.isComplated,
    this.canScrape,
    this.images,
    this.businessItems,
    this.insertBy,
    this.vinNumber,
    this.carYearId,
    this.carYear,
    this.carModelId,
    this.carModel,
    this.globalCustomerId,
    required this.isInStock,
  });

  factory ItemResponseModel.fromJson(Map<String, dynamic> json) {
    return ItemResponseModel(
      itemId: json['itemId'] ?? 0,

      itemDescription: json['itemDescription'],
      itemDetails: json['itemDetails'],
      sku: json['sku'],
      internetId: json['internetId'],
      upc: json['upc'],
      shortCode: json['shortCode'],
      model: json['model'],

      platformId: json['platformId'],
      platform: json['platform'],

      height: _toDouble(json['height']),
      width: _toDouble(json['width']),
      length: _toDouble(json['length']),

      unitId: json['unitId'],
      unit: json['unit'],
      unitValue: _toDouble(json['unitValue']),

      colorId: json['colorId'],
      color: json['color'],

      carBrandId: json['carBrandId'],
      carBrand: json['carBrand'],

      description: json['description'],
      weight: _toDouble(json['weight']),
      internet: json['internet'],

      sizeId: json['sizeId'],
      size: json['size'],

      categoryId: json['categoryId'],
      category: json['category'],

      basePrice: _toDouble(json['basePrice']),

      currencyId: json['currencyId'],
      currency: json['currency'],

      isActive: json['isActive'],
      isScraped: json['isScraped'],
      isComplated: json['isComplated'],
      canScrape: json['canScrape'],

      images: json['images'],
      businessItems: json['businessItems'],

      insertBy: json['insertBy'],

      vinNumber: json['vinNumber'],

      carYearId: json['carYearId'],
      carYear: json['carYear'],

      carModelId: json['carModelId'],
      carModel: json['carModel'],

      globalCustomerId: json['globalCustomerId'],

      isInStock: json['isInStock'] ?? false,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}