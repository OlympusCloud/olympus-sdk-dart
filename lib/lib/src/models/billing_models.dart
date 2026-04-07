/// Models for the Olympus Billing service.
library;

/// A billing plan (Ember, Spark, Blaze, Inferno, Olympus).
class Plan {
  const Plan({
    required this.id,
    required this.name,
    this.tier,
    this.monthlyPrice,
    this.annualPrice,
    this.maxLocations,
    this.maxAgents,
    this.aiCredits,
    this.voiceMinutes,
    this.features,
    this.status,
  });

  final String id;
  final String name;
  final String? tier;

  /// Monthly price in cents.
  final int? monthlyPrice;

  /// Annual price in cents.
  final int? annualPrice;
  final int? maxLocations;
  final int? maxAgents;
  final int? aiCredits;
  final int? voiceMinutes;
  final List<String>? features;
  final String? status;

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'] as String? ?? json['plan_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    tier: json['tier'] as String?,
    monthlyPrice: json['monthly_price'] as int?,
    annualPrice: json['annual_price'] as int?,
    maxLocations: json['max_locations'] as int?,
    maxAgents: json['max_agents'] as int?,
    aiCredits: json['ai_credits'] as int?,
    voiceMinutes: json['voice_minutes'] as int?,
    features: (json['features'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (tier != null) 'tier': tier,
    if (monthlyPrice != null) 'monthly_price': monthlyPrice,
    if (annualPrice != null) 'annual_price': annualPrice,
    if (maxLocations != null) 'max_locations': maxLocations,
    if (maxAgents != null) 'max_agents': maxAgents,
    if (aiCredits != null) 'ai_credits': aiCredits,
    if (voiceMinutes != null) 'voice_minutes': voiceMinutes,
    if (features != null) 'features': features,
    if (status != null) 'status': status,
  };
}

/// Tenant resource usage for a billing period.
class UsageReport {
  const UsageReport({
    this.period,
    this.aiCreditsUsed,
    this.aiCreditsLimit,
    this.voiceMinutesUsed,
    this.voiceMinutesLimit,
    this.storageUsedMb,
    this.storageLimitMb,
    this.apiCallsCount,
    this.locationCount,
    this.agentCount,
  });

  final String? period;
  final int? aiCreditsUsed;
  final int? aiCreditsLimit;
  final int? voiceMinutesUsed;
  final int? voiceMinutesLimit;
  final int? storageUsedMb;
  final int? storageLimitMb;
  final int? apiCallsCount;
  final int? locationCount;
  final int? agentCount;

  factory UsageReport.fromJson(Map<String, dynamic> json) => UsageReport(
    period: json['period'] as String?,
    aiCreditsUsed: json['ai_credits_used'] as int?,
    aiCreditsLimit: json['ai_credits_limit'] as int?,
    voiceMinutesUsed: json['voice_minutes_used'] as int?,
    voiceMinutesLimit: json['voice_minutes_limit'] as int?,
    storageUsedMb: json['storage_used_mb'] as int?,
    storageLimitMb: json['storage_limit_mb'] as int?,
    apiCallsCount: json['api_calls_count'] as int?,
    locationCount: json['location_count'] as int?,
    agentCount: json['agent_count'] as int?,
  );

  Map<String, dynamic> toJson() => {
    if (period != null) 'period': period,
    if (aiCreditsUsed != null) 'ai_credits_used': aiCreditsUsed,
    if (aiCreditsLimit != null) 'ai_credits_limit': aiCreditsLimit,
    if (voiceMinutesUsed != null) 'voice_minutes_used': voiceMinutesUsed,
    if (voiceMinutesLimit != null) 'voice_minutes_limit': voiceMinutesLimit,
    if (storageUsedMb != null) 'storage_used_mb': storageUsedMb,
    if (storageLimitMb != null) 'storage_limit_mb': storageLimitMb,
    if (apiCallsCount != null) 'api_calls_count': apiCallsCount,
    if (locationCount != null) 'location_count': locationCount,
    if (agentCount != null) 'agent_count': agentCount,
  };

  double get aiCreditsPercentage =>
      (aiCreditsLimit != null && aiCreditsLimit! > 0)
      ? (aiCreditsUsed ?? 0) / aiCreditsLimit!
      : 0.0;

  double get voiceMinutesPercentage =>
      (voiceMinutesLimit != null && voiceMinutesLimit! > 0)
      ? (voiceMinutesUsed ?? 0) / voiceMinutesLimit!
      : 0.0;
}

/// A billing invoice.
class Invoice {
  const Invoice({
    required this.id,
    this.status,
    this.amount,
    this.currency,
    this.periodStart,
    this.periodEnd,
    this.paidAt,
    this.pdfUrl,
    this.lineItems,
  });

  final String id;
  final String? status;

  /// Amount in cents.
  final int? amount;
  final String? currency;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? paidAt;
  final String? pdfUrl;
  final List<InvoiceLineItem>? lineItems;

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'] as String? ?? json['invoice_id'] as String? ?? '',
    status: json['status'] as String?,
    amount: json['amount'] as int?,
    currency: json['currency'] as String?,
    periodStart: json['period_start'] != null
        ? DateTime.parse(json['period_start'] as String)
        : null,
    periodEnd: json['period_end'] != null
        ? DateTime.parse(json['period_end'] as String)
        : null,
    paidAt: json['paid_at'] != null
        ? DateTime.parse(json['paid_at'] as String)
        : null,
    pdfUrl: json['pdf_url'] as String?,
    lineItems: (json['line_items'] as List<dynamic>?)
        ?.map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (status != null) 'status': status,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    if (periodStart != null) 'period_start': periodStart!.toIso8601String(),
    if (periodEnd != null) 'period_end': periodEnd!.toIso8601String(),
    if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
    if (pdfUrl != null) 'pdf_url': pdfUrl,
    if (lineItems != null)
      'line_items': lineItems!.map((e) => e.toJson()).toList(),
  };
}

/// A single line item on an invoice.
class InvoiceLineItem {
  const InvoiceLineItem({
    required this.description,
    this.amount,
    this.quantity,
  });

  final String description;

  /// Amount in cents.
  final int? amount;
  final int? quantity;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) =>
      InvoiceLineItem(
        description: json['description'] as String? ?? '',
        amount: json['amount'] as int?,
        quantity: json['quantity'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'description': description,
    if (amount != null) 'amount': amount,
    if (quantity != null) 'quantity': quantity,
  };
}
