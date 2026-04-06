/// Models for the Olympus Marketplace service.
library;

/// An app listed on the Olympus Marketplace.
class MarketplaceApp {
  const MarketplaceApp({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.industry,
    this.developer,
    this.iconUrl,
    this.rating,
    this.installCount,
    this.pricing,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? industry;
  final String? developer;
  final String? iconUrl;
  final double? rating;
  final int? installCount;
  final String? pricing;
  final DateTime? createdAt;

  factory MarketplaceApp.fromJson(Map<String, dynamic> json) => MarketplaceApp(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        industry: json['industry'] as String?,
        developer: json['developer'] as String?,
        iconUrl: json['icon_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        installCount: json['install_count'] as int?,
        pricing: json['pricing'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (industry != null) 'industry': industry,
        if (developer != null) 'developer': developer,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (rating != null) 'rating': rating,
        if (installCount != null) 'install_count': installCount,
        if (pricing != null) 'pricing': pricing,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

/// An installed marketplace app instance for a tenant.
class Installation {
  const Installation({
    required this.id,
    required this.appId,
    this.appName,
    this.status,
    this.config,
    this.installedAt,
  });

  final String id;
  final String appId;
  final String? appName;
  final String? status;
  final Map<String, dynamic>? config;
  final DateTime? installedAt;

  factory Installation.fromJson(Map<String, dynamic> json) => Installation(
        id: json['id'] as String? ?? json['installation_id'] as String? ?? '',
        appId: json['app_id'] as String,
        appName: json['app_name'] as String?,
        status: json['status'] as String?,
        config: json['config'] as Map<String, dynamic>?,
        installedAt: json['installed_at'] != null
            ? DateTime.parse(json['installed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'app_id': appId,
        if (appName != null) 'app_name': appName,
        if (status != null) 'status': status,
        if (config != null) 'config': config,
        if (installedAt != null)
          'installed_at': installedAt!.toIso8601String(),
      };
}
