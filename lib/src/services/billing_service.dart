import '../http_client.dart';
import '../models/billing_models.dart';

/// Subscription billing, usage metering, invoices, and plan management.
///
/// Wraps the Olympus Billing service (Rust Platform + Stripe) via the Go API
/// Gateway.
/// Routes: `/billing/*`, `/platform/subscription`.
class OlympusBillingService {
  OlympusBillingService(this._http);

  final OlympusHttpClient _http;

  /// Get the current subscription plan for the tenant.
  Future<Plan> getCurrentPlan() async {
    final json = await _http.get('/billing/subscription');
    return Plan.fromJson(json);
  }

  /// Get resource usage for the current billing period.
  Future<UsageReport> getUsage({String? period}) async {
    final json = await _http.get('/billing/stats', queryParameters: {
      'period': ?period,
    });
    return UsageReport.fromJson(json);
  }

  /// List invoices for the tenant.
  Future<List<Invoice>> getInvoices() async {
    final json = await _http.get('/billing/invoices');
    final items = json['invoices'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single invoice by ID.
  Future<Invoice> getInvoice(String invoiceId) async {
    final json = await _http.get('/billing/invoices/$invoiceId');
    return Invoice.fromJson(json);
  }

  /// Download an invoice PDF. Returns the PDF URL.
  Future<String> getInvoicePdf(String invoiceId) async {
    final json = await _http.get('/billing/invoices/$invoiceId/pdf');
    return json['url'] as String? ?? json['pdf_url'] as String? ?? '';
  }

  /// Upgrade (or downgrade) to a different plan.
  Future<Plan> upgradePlan(String planId) async {
    final json = await _http.put('/billing/subscription/plan', data: {
      'plan_id': planId,
    });
    return Plan.fromJson(json);
  }

  /// List all available billing plans.
  Future<List<Plan>> listPlans() async {
    final json = await _http.get('/platform/billing/plans');
    final items =
        json['plans'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => Plan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Add a payment method.
  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> method) async {
    return _http.post('/billing/payment-methods', data: method);
  }

  /// Remove a payment method.
  Future<void> removePaymentMethod(String methodId) async {
    await _http.delete('/billing/payment-methods/$methodId');
  }
}
