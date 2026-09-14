class PlatformModel {
  final int? platformId;
  final String? description;

  PlatformModel({
    this.platformId,
    this.description,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      platformId: json['platform_id'],
      description: json['description'],
    );
  }
}