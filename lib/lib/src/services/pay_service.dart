import '../http_client.dart';
import '../models/pay_models.dart';

/// Payment processing, refunds, balance, payouts, and terminal management.
///
/// Wraps the Olympus Payment Orchestration service via the Go API Gateway.
/// Routes: `/payments/*`, `/finance/*`, `/stripe/terminal/*`.
///
/// ```dart
/// final oc = OlympusClient(appId: 'com.my-app', apiKey: 'oc_live_...');
///
/// // Charge an order
/// final payment = await oc.pay.charge('order-123', 2499, 'pm_card_visa');
///
/// // Capture a pre-authorized hold
/// await oc.pay.capture(payment.id);
///
/// // Register a card reader
/// final reader = await oc.pay.createTerminalReader(
///   locationId: 'tml_loc_abc',
///   registrationCode: 'simulated-wpe',
/// );
/// ```
class OlympusPayService {
  OlympusPayService(this._http);

  final OlympusHttpClient _http;

  // ---------------------------------------------------------------------------
  // Payment intents
  // ---------------------------------------------------------------------------

  /// Charge an order using the given payment method.
  ///
  /// [amount] is in cents. [method] is a payment method token or ID
  /// (e.g., a Stripe payment method ID or "cash").
  Future<Payment> charge(String orderId, int amount, String method) async {
    final json = await _http.post(
      '/payments/intents',
      data: {'order_id': orderId, 'amount': amount, 'payment_method': method},
    );
    return Payment.fromJson(json);
  }

  /// Capture a previously authorized payment.
  Future<Payment> capture(String paymentId) async {
    final json = await _http.post('/payments/$paymentId/capture');
    return Payment.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Refunds
  // ---------------------------------------------------------------------------

  /// Refund a payment, optionally partially.
  ///
  /// If [amount] is null the full payment is refunded.
  Future<Refund> refund(String paymentId, {int? amount, String? reason}) async {
    final json = await _http.post(
      '/payments/$paymentId/refund',
      data: {'amount': ?amount, 'reason': ?reason},
    );
    return Refund.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Balance & payouts
  // ---------------------------------------------------------------------------

  /// Get the current account balance.
  Future<Balance> getBalance() async {
    final json = await _http.get('/finance/balance');
    return Balance.fromJson(json);
  }

  /// Initiate a payout to an external destination.
  ///
  /// [method] is either "standard" (1-2 business days) or "instant".
  Future<Payout> createPayout(
    int amount,
    String destination, {
    String? currency,
    String? method,
    String? description,
  }) async {
    final json = await _http.post(
      '/finance/payouts',
      data: {
        'amount': amount,
        'destination': destination,
        'currency': ?currency,
        'method': ?method,
        'description': ?description,
      },
    );
    return Payout.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Payment listing
  // ---------------------------------------------------------------------------

  /// List recent payments for the tenant.
  ///
  /// Supports pagination via [page] and [limit], and filtering by [status]
  /// (e.g., "succeeded", "pending", "failed").
  Future<List<Payment>> listPayments({
    int? page,
    int? limit,
    String? status,
  }) async {
    final json = await _http.get(
      '/payments',
      queryParameters: {'page': ?page, 'limit': ?limit, 'status': ?status},
    );
    final items =
        json['payments'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Terminal — card reader management
  // ---------------------------------------------------------------------------

  /// Register a physical card reader (e.g., Stripe BBPOS WisePOS E).
  ///
  /// [locationId] is the Stripe Terminal location ID.
  /// [registrationCode] is the pairing code displayed on the reader.
  Future<TerminalReader> createTerminalReader({
    required String locationId,
    required String registrationCode,
    String? label,
  }) async {
    final json = await _http.post(
      '/stripe/terminal/readers',
      data: {
        'location_id': locationId,
        'registration_code': registrationCode,
        'label': ?label,
      },
    );
    return TerminalReader.fromJson(json);
  }

  /// Capture a payment on a terminal reader.
  ///
  /// Creates a PaymentIntent and presents it to the reader for
  /// tap/insert/swipe collection.
  ///
  /// [readerId] is the Stripe Terminal reader ID (e.g., "tmr_xxx").
  /// [amount] is in cents.
  Future<TerminalPayment> captureTerminalPayment(
    String readerId,
    int amount, {
    String? currency,
    String? description,
  }) async {
    final json = await _http.post(
      '/stripe/terminal/readers/$readerId/process',
      data: {
        'amount': amount,
        'currency': ?currency,
        'description': ?description,
      },
    );
    return TerminalPayment.fromJson(json);
  }
}
