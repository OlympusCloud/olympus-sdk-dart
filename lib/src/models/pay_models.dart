/// Models for the Olympus Pay service.
library;

/// A completed or pending payment.
class Payment {
  const Payment({
    required this.id,
    required this.status,
    this.orderId,
    this.amount,
    this.currency,
    this.method,
    this.stripePaymentIntentId,
    this.createdAt,
  });

  final String id;
  final String status;
  final String? orderId;

  /// Amount in cents.
  final int? amount;
  final String? currency;
  final String? method;
  final String? stripePaymentIntentId;
  final DateTime? createdAt;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String? ?? json['payment_id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    orderId: json['order_id'] as String?,
    amount: json['amount'] as int?,
    currency: json['currency'] as String?,
    method: json['method'] as String? ?? json['payment_method'] as String?,
    stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    if (orderId != null) 'order_id': orderId,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    if (method != null) 'method': method,
    if (stripePaymentIntentId != null)
      'stripe_payment_intent_id': stripePaymentIntentId,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

/// A refund issued against a payment.
class Refund {
  const Refund({
    required this.id,
    required this.paymentId,
    required this.status,
    this.amount,
    this.reason,
    this.createdAt,
  });

  final String id;
  final String paymentId;
  final String status;

  /// Amount in cents (null = full refund).
  final int? amount;
  final String? reason;
  final DateTime? createdAt;

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    id: json['id'] as String? ?? json['refund_id'] as String? ?? '',
    paymentId: json['payment_id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    amount: json['amount'] as int?,
    reason: json['reason'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'payment_id': paymentId,
    'status': status,
    if (amount != null) 'amount': amount,
    if (reason != null) 'reason': reason,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

/// Account balance information.
class Balance {
  const Balance({
    required this.available,
    required this.pending,
    this.currency,
  });

  /// Available balance in cents.
  final int available;

  /// Pending balance in cents.
  final int pending;
  final String? currency;

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    available: json['available'] as int? ?? 0,
    pending: json['pending'] as int? ?? 0,
    currency: json['currency'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'available': available,
    'pending': pending,
    if (currency != null) 'currency': currency,
  };

  int get total => available + pending;
}

/// A payout to an external bank account or destination.
class Payout {
  const Payout({
    required this.id,
    required this.status,
    this.amount,
    this.currency,
    this.destination,
    this.method,
    this.arrivalDate,
    this.createdAt,
  });

  final String id;
  final String status;

  /// Amount in cents.
  final int? amount;
  final String? currency;
  final String? destination;

  /// "standard" or "instant".
  final String? method;
  final DateTime? arrivalDate;
  final DateTime? createdAt;

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
    id: json['id'] as String? ?? json['payout_id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    amount: json['amount'] as int?,
    currency: json['currency'] as String?,
    destination: json['destination'] as String?,
    method: json['method'] as String?,
    arrivalDate: json['arrival_date'] != null
        ? DateTime.parse(json['arrival_date'] as String)
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    if (destination != null) 'destination': destination,
    if (method != null) 'method': method,
    if (arrivalDate != null) 'arrival_date': arrivalDate!.toIso8601String(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

/// A physical card reader registered via Stripe Terminal.
class TerminalReader {
  const TerminalReader({
    required this.id,
    this.deviceType,
    this.label,
    this.locationId,
    this.serialNumber,
    this.status,
    this.ipAddress,
  });

  final String id;
  final String? deviceType;
  final String? label;
  final String? locationId;
  final String? serialNumber;

  /// "online" or "offline".
  final String? status;
  final String? ipAddress;

  factory TerminalReader.fromJson(Map<String, dynamic> json) => TerminalReader(
    id: json['id'] as String? ?? '',
    deviceType: json['device_type'] as String?,
    label: json['label'] as String?,
    locationId: json['location'] as String? ?? json['location_id'] as String?,
    serialNumber: json['serial_number'] as String?,
    status: json['status'] as String?,
    ipAddress: json['ip_address'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (deviceType != null) 'device_type': deviceType,
    if (label != null) 'label': label,
    if (locationId != null) 'location': locationId,
    if (serialNumber != null) 'serial_number': serialNumber,
    if (status != null) 'status': status,
    if (ipAddress != null) 'ip_address': ipAddress,
  };
}

/// The result of presenting a payment to a terminal reader.
class TerminalPayment {
  const TerminalPayment({
    required this.id,
    required this.status,
    this.amount,
    this.currency,
    this.readerId,
    this.paymentIntentId,
    this.createdAt,
  });

  final String id;
  final String status;

  /// Amount in cents.
  final int? amount;
  final String? currency;
  final String? readerId;
  final String? paymentIntentId;
  final DateTime? createdAt;

  factory TerminalPayment.fromJson(Map<String, dynamic> json) =>
      TerminalPayment(
        id: json['id'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        amount: json['amount'] as int?,
        currency: json['currency'] as String?,
        readerId: json['reader_id'] as String?,
        paymentIntentId:
            json['payment_intent_id'] as String? ??
            json['payment_intent'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    if (readerId != null) 'reader_id': readerId,
    if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
