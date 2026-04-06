# Olympus SDK for Dart

Official SDK for building apps on [Olympus Cloud](https://olympuscloud.ai) — the AI Business Operating System.

## Quick Start

```dart
import 'package:olympus_sdk/olympus_sdk.dart';

final oc = OlympusClient(
  appId: 'com.my-app',
  apiKey: 'sk_live_...',
);

// Create an order
final order = await oc.commerce.createOrder(
  items: [OrderItem(catalogId: 'burger', qty: 2, price: 1299)],
  source: 'pos',
);

// Process payment
final payment = await oc.pay.charge(order.id, order.total, 'card');

// Ask AI
final answer = await oc.ai.query('What are our top sellers today?');

// Send notification
await oc.notify.push('user-123', 'Order Ready', 'Your order #${order.orderNumber} is ready!');
```

## Services

| Service | Access | Description |
|---------|--------|-------------|
| `oc.auth` | Auth | Login, SSO, users, roles, API keys |
| `oc.commerce` | Commerce | Orders, catalog, checks, inventory |
| `oc.ai` | AI (The Ether) | Query, chat, agents, RAG search, STT/TTS |
| `oc.pay` | Payments | Charge, refund, balance, payouts |
| `oc.notify` | Notifications | Push, SMS, email, Slack, chat |
| `oc.events` | Events | Subscribe, publish, webhooks |
| `oc.data` | Data | Query, insert, update, delete, search |
| `oc.storage` | Storage | Upload, download, presigned URLs |
| `oc.marketplace` | Marketplace | Browse, install, review apps |
| `oc.billing` | Billing | Plans, usage, invoices |
| `oc.gating` | Feature Flags | Check flags, evaluate policies |
| `oc.devices` | Devices | MDM, kiosk mode, OTA updates |
| `oc.observe` | Observability | Events, errors, traces |

## Installation

```yaml
# pubspec.yaml
dependencies:
  olympus_sdk: ^0.1.0
```

## Configuration

```dart
// Production
final oc = OlympusClient(appId: 'com.my-app', apiKey: 'sk_live_...');

// Sandbox (for testing)
final oc = OlympusClient.sandbox(appId: 'com.my-app', apiKey: 'sk_sandbox_...');

// Custom config
final oc = OlympusClient(config: OlympusConfig(
  appId: 'com.my-app',
  apiKey: 'sk_live_...',
  baseUrl: 'https://custom.api.olympuscloud.ai/api/v1',
));
```

## olympus.yaml

Every app has an `olympus.yaml` at the repo root that declares platform services, scopes, webhooks, and marketplace config. See `examples/restaurant-revolution.olympus.yaml` for a complete example.

## License

Proprietary — NebusAI Holdings. See LICENSE file.
