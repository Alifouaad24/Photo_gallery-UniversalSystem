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