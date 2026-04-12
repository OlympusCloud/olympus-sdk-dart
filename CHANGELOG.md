# Changelog

## 0.4.0 (2026-04-12)

### Voice Agent Self-Service (epic OlympusCloud/orderecho-ai#119)

`oc.voice` extended with the methods that back the OrderEcho Agent Editor.
Restaurants now manage every aspect of their voice agents from the app —
voice character, persona, ambient background sound, voice tuning, templates
and clones — without any code changes.

**New methods:**
- `listAgents`, `getAgent`, `createAgent`, `updateAgent`, `deleteAgent`,
  `cloneAgent` — full agent CRUD aliased on `/voice-agents/configs/*`
- `previewAgentVoice(agentId, sampleText, voiceId?, voiceOverrides?)` —
  generate a TTS sample for the editor's voice picker without making a call
- `listGeminiVoices()` — Gemini Live voice catalog (Aoede, Charon, Fenrir,
  Kore, Leda, Orus, Puck, Zephyr) plus tenant marketplace voices, each with
  a sample audio URL
- `listPersonas({category, industry, premiumOnly})` — curated voice persona
  library (Italian-American line cook, Tampa friendly host, casual bartender,
  fine-dining host, coffee shop barista...)
- `getPersona(idOrSlug)`, `applyPersonaToAgent(agentId, personaIdOrSlug)`
- `listAgentTemplates({scope})`, `instantiateAgentTemplate`,
  `publishAgentAsTemplate` — agent template lifecycle (tenant-private and
  global scopes)
- `listAmbianceLibrary({category})`, `uploadAmbianceBed(audio, name, ...)` —
  background ambient bed catalog and custom upload
- `updateAgentAmbiance(agentId, {enabled, intensity, defaultR2Key,
  timeOfDayVariants})` — per-agent ambiance configuration
- `updateAgentVoiceOverrides(agentId, {pitch, speed, warmth,
  regionalDialect})` — voice tuning sliders

**Backing platform changes:** new `voice_agent_configs.ambiance_config` and
`voice_agent_configs.voice_overrides` JSON columns plus `voice_personas`
table seeded with 5 starter personas. See platform commit `d8d60cccf`.

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
