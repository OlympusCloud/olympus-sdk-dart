# Changelog

## 0.3.2 (2026-04-11)

### Voice Customization (Issue #82)

Tenants can now fine-tune their selected voice with four sliders:

- **`pitch`** (0.5–2.0, default 1.0) — perceived voice height.
- **`rate`** (0.5–2.0, default 1.0) — speaking speed.
- **`warmth`** (0.0–1.0, default 0.7) — friendliness/casualness hint.
- **`formality`** (0.0–1.0, default 0.5) — professional vs casual hint.

New model `VoiceProfile` plus `VoiceProfileBounds` (clamp helpers), and
a new service accessor `oc.voiceProfile` with `getVoiceProfile(agentId)`,
`updateVoiceProfile(agentId, profile)`, and `resetVoiceProfile(agentId)`.

Pitch and rate are applied to cached TTS via SSML prosody tags. Warmth
and formality are injected as tone hints into the Gemini Live voice
persona preamble (Gemini Live does not natively accept pitch/rate).

## 0.3.1 (2026-04-11)

### Voice Library (Issue #81)

Tenants can now pick which of the 8 prebuilt Gemini Live voices their
phone agent uses. Voice is the strongest brand signal on a phone call —
a steakhouse and a bubble tea shop should not sound the same.

- **New model** — `VoiceOption` with `{id, name, gender, description, sampleUrl}`.
- **`oc.voice.listVoices()`** — returns `List<VoiceOption>` for the 8 Gemini
  voices (Kore, Aoede, Leda, Puck, Charon, Fenrir, Orus, Zephyr), cached
  in-memory. Each voice ships with a 5-second sample clip hosted on R2 so
  apps can preview before selecting. Pass `forceRefresh: true` to bypass
  the cache.
- **`oc.voice.updateAgentVoice(agentId, voiceName)`** — persists the chosen
  voice to `voice_agent_configs.voice_profile`. Takes effect on the next
  inbound call.
- **`oc.voice.getAgentVoice(agentId)`** — returns the current voice name,
  falling back to `Kore` if none configured.
- **`oc.voice.clearVoiceLibraryCache()`** — clear the in-memory catalog cache.

### Breaking: `listVoices` signature change

The previous `oc.voice.listVoices()` targeted the community voice
marketplace and returned `List<Map<String, dynamic>>`. It has been renamed
to **`listMarketplaceVoices()`** with an identical signature. The new
`listVoices()` returns `List<VoiceOption>` for the built-in Gemini
library. No apps in the workspace called the old method, but third-party
apps upgrading from 0.3.0 should rename their calls.

## 0.3.0 (2026-04-10)

### New Services (6)

- **`oc.creator`** — Creator platform (posts, media, episodes, profile, analytics, team, branding, calendar, AI content generation, social posts, shows). Wraps Rust Creator service (14 handler modules). Issue #2839
- **`oc.platform`** — Tenant lifecycle: signup, cleanup, health, onboarding progress. Issues #2845, #2846
- **`oc.developer`** — Developer Platform: API keys (create/list/revoke/rotate), DevBox sandbox provisioning, DevBox collaborators, canary deployments (deploy/promote/rollback). Issues #2834, #2835, #2828, #2829
- **`oc.business`** — Business data access: revenue summary/trends, top sellers, on-duty staff, AI insights, period comparisons. Issue #2570
- **`oc.maximus`** — Maximus consumer AI assistant: voice query, wake word config, calendar, email, subscription plans. Issues #2567, #2568, #2571
- **`oc.pos`** — POS voice order integration (Square/Toast/Clover), menu sync, order status. Issue #2453

### Extended Services

- **`oc.voice`** — Added caller profiles (`getCallerProfile`, `listCallerProfiles`, `upsertCallerProfile`, `recordCallerOrder`), escalation config (`getEscalationConfig`, `updateEscalationConfig`), business hours (`getBusinessHours`, `updateBusinessHours`). Issues #2868, #2870
- **`oc.training`** — Added menu translations (`generateTranslations`, `getTranslations`, `updateTranslation`, `approveTranslations`, `deleteTranslations`, `listSupportedLanguages`). Issue #2869
- **`oc.smartHome`** — Added scenes (`listScenes`, `activateScene`, `createScene`, `deleteScene`) and automations (`listAutomations`, `createAutomation`, `deleteAutomation`). Issue #2569

### Backend Features Exposed

This release exposes all features from monorepo Rounds 1-8:
- Service JWT auth infrastructure (#2848)
- 6 new OAuth providers: Instagram, Twitter/X, LinkedIn, YouTube, TikTok, Rumble (#2840)
- CI/CD quality gates (#2837)
- Secret Manager consolidation (#2847)
- Minerva architect review (#2836) — callable via `oc.developer.*` review endpoints
- DevBox multiplayer collaboration (#2828)
- Guardian context-aware standards enforcement (#2871)

### Migration Notes

No breaking changes. All existing service accessors continue to work.

To use the new services in your app:

```dart
final oc = OlympusClient(appId: 'com.my-app', apiKey: '...');

// New services
final posts = await oc.creator.listPosts();
final signup = await oc.platform.signup(
  companyName: 'Acme', adminEmail: '...', adminName: '...', industry: 'restaurant',
);
final key = await oc.developer.createApiKey('dev_123', appId: 'app_456', name: 'Production');
final revenue = await oc.business.getRevenueSummary();
final response = await oc.maximus.voiceQuery('What are my top sellers today?');
final order = await oc.pos.submitVoiceOrder(tenantId: '...', locationId: '...', items: [...]);

// Extended services
final caller = await oc.voice.getCallerProfile('+16504371908');
await oc.training.generateTranslations('es');
await oc.smartHome.activateScene('movie_night');
```

## 0.2.0

- Added 6 services: identity, vision, wearable, genui, ads, live activity
- Agent service for multi-tenant marketplace checkout

## 0.1.0

- Initial release with 20 core services
