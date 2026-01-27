class UserResponse {
  final String email;
  final String userName;
  final List<Business> businesses;

  UserResponse({
    required this.email,
    required this.userName,
    required this.businesses,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      email: json['email'],
      userName: json['userName'],
      businesses: (json['businesses'] as List)
          .map((e) => Business.fromJson(e))
          .toList(),
    );
  }
}


class Business {
  final int businessId;
  final String businessName;
  final String businessLogoUrl;
  final int countryId;
  final bool isActive;
  final String? businessPhone;
  final String? businessEmail;
  final List<Activity> activities;
  final List<BusinessTypeLink> businessTypes;
  final List<BusinessService> businessServices;

  Business({
    required this.businessId,
    required this.businessName,
    required this.businessLogoUrl,
    required this.countryId,
    required this.isActive,
    this.businessPhone,
    this.businessEmail,
    required this.activities,
    required this.businessTypes,
    required this.businessServices,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      businessId: json['business_id'],
      businessName: json['business_name'],
      businessLogoUrl: json['business_LogoUrl'] ?? '',
      countryId: json['countryId'],
      isActive: json['is_active'],
      businessPhone: json['business_phone'],
      businessEmail: json['business_email'],
      activities: (json['activities'] as List)
          .map((e) => Activity.fromJson(e))
          .toList(),
      businessTypes: (json['businessTypes'] as List)
          .map((e) => BusinessTypeLink.fromJson(e))
          .toList(),
      businessServices: (json['business_Services'] as List)
          .map((e) => BusinessService.fromJson(e))
          .toList(),
    );
  }
}


class Activity {
  final int activityId;
  final String description;
  final bool visible;

  Activity({
    required this.activityId,
    required this.description,
    required this.visible,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activity_id'],
      description: json['description'],
      visible: json['visible'],
    );
  }
}

class BusinessTypeLink {
  final int businessTypeId;
  final BusinessType businessType;

  BusinessTypeLink({
    required this.businessTypeId,
    required this.businessType,
  });

  factory BusinessTypeLink.fromJson(Map<String, dynamic> json) {
    return BusinessTypeLink(
      businessTypeId: json['business_type_id'],
      businessType: BusinessType.fromJson(json['businessType']),
    );
  }
}

class BusinessType {
  final int businessTypeId;
  final String description;

  BusinessType({
    required this.businessTypeId,
    required this.description,
  });

  factory BusinessType.fromJson(Map<String, dynamic> json) {
    return BusinessType(
      businessTypeId: json['business_type_id'],
      description: json['description'],
    );
  }
}


class BusinessService {
  final int businessId;
  final int serviceId;

  BusinessService({
    required this.businessId,
    required this.serviceId,
  });

  factory BusinessService.fromJson(Map<String, dynamic> json) {
    return BusinessService(
      businessId: json['business_id'],
      serviceId: json['service_id'],
    );
  }
}
