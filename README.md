> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Flutter HealthKit

A Flutter client for the **Huawei Health Kit REST API** — OAuth2 login, data collector management, and reading/writing health records and continuous samples.

This project is primarily a reference implementation: a real-world example of integrating a third-party health platform API into a Flutter app, including the rough edges (OAuth via WebView, token refresh, nanosecond timestamps, two different "read data" endpoints) that API docs tend to gloss over.

## Features

- OAuth2 login against Huawei's Health Kit, via an in-app WebView
- Automatic access-token refresh on 401, with retry
- List, create, update, and delete **data collectors** (the core entity every health record/sample belongs to)
- Insert structured health records (e.g. sleep sessions) and upload continuous sample data (e.g. steps)
- View a collector's recorded data, automatically routed to the correct read endpoint for its data type
- Typed API error surfacing (real server error messages, not generic failures)

## Architecture

The codebase is split into two layers:

- **`lib/core`** — everything that isn't tied to a specific feature: network models, the two API services (`AuthService`, `HealthKitService`), environment configuration, navigation, theming, and domain-wide constants/models.
- **`lib/feature`** — UI and feature-specific state, organized by feature (`health`, `home`, `login`, `splash`).

### State management: Riverpod

All state is managed with [`flutter_riverpod`](https://riverpod.dev), using `AsyncNotifier`/`AsyncNotifierProvider` throughout — no `StateNotifier`, no raw `Provider` for mutable state, no `setState` outside of local form UI state.

A few patterns recur across the notifiers:

| Pattern | Where | Why |
|---|---|---|
| Plain `AsyncNotifierProvider` | `dataCollectorsNotifierProvider` | Caches the collector list app-wide; `addOrUpdate`/`remove` mutate the cache in place after a write, instead of refetching. |
| `AsyncNotifierProvider.family` | `dataCollectorDetailNotifierProvider(collectorId)` | One independent async state per collector, keyed by ID. |
| `AutoDisposeAsyncNotifierProvider` | `createDataCollectorNotifierProvider`, `insertHealthRecordsNotifierProvider`, etc. | One-shot write operations tied to a form's lifetime — state is thrown away once the sheet closes. |
| `AsyncValue.guard` + a typed exception | every notifier's write path | `HealthKitApiException` carries the API's real error message into `AsyncError`, so the UI can show it directly instead of a generic "something went wrong". |

Cache invalidation is deliberately **not** done on logout — invalidating a still-watched provider mid-token-clear races the token removal and can cache an empty result. Instead, `dataCollectorsNotifierProvider` is invalidated right after a **successful login**, when a valid token is guaranteed to exist.

### Services

Two services live in `lib/core/network/service.dart`, each owning its own `Dio` instance and its own auth interceptor (a shared instance would only refresh tokens for whichever service was wired up first):

- **`AuthService`** — OAuth token exchange (`postOAuthToken`), silent refresh (`refreshAccessToken`), session check (`hasSession`), `logout`. Retries a request once after a successful refresh; a second 401 is treated as a dead session.
- **`HealthKitService`** — everything under `/healthkit/v2`: `queryDataCollectors`, `createDataCollector`, `updateDataCollector`, `deleteDataCollector`, `insertHealthRecords`, `uploadSampleData`, `queryHealthRecords`, `querySampleSetsHistory`, `deleteHealthRecords`, `deleteSampleSet`. Failures throw `HealthKitApiException` (parsed from the API's `{"error": {"code", "message"}}` body) instead of returning `null` silently.

Both are exposed to the widget tree via Riverpod providers in `lib/core/service/health_providers.dart`, so notifiers depend on the provider, not a concrete instance — tests can override `healthKitServiceProvider` with a fake.

### Models

Two kinds of models live under `lib/core`, kept deliberately separate:

- **`lib/core/network/model/`** — raw request/response shapes for the Huawei API, one file per endpoint family (`general_data_collector_*`, `sample_data_upload_*`, `health_records_query_*`, `sample_sets_history_*`). These mirror the wire format field-for-field.
- **`lib/core/model/`** — domain-level types that don't belong to one specific request: `HealthDataType` (the small set of confirmed `dataTypeName` values) and `DetailRecordEntry` (a normalized shape the detail screen renders, regardless of which of the two read endpoints produced it).

A quirk worth knowing before you extend this: Huawei's API returns timestamps as Unix epoch **nanoseconds**, not milliseconds. `lib/feature/health/util/nanoseconds.dart` converts to/from Dart's microsecond-precision `DateTime` — the conversion is lossless because every timestamp observed from the API lands on a millisecond boundary.

It also splits "give me this collector's data" across two endpoints depending on the data type:

- `dataTypeName` starting with `com.huawei.health.*` (e.g. sleep) → `GET /dataCollectors/{id}/healthRecords`, a plain date-range query.
- everything else (continuous samples like steps) → `GET /dataCollectors/{id}/sampleSets/history`, a **cursor-based delta sync** (`insertedSamplePoint`/`deletedSamplePoint`/`cursor`/`hasMoreData`), not a range query at all.

`DataCollectorDetailNotifier` picks the right one automatically and normalizes both into `DetailRecordEntry`, so the UI never needs to know which endpoint answered.

### UI: atomic design

`lib/feature/health/view/widgets/` follows [atomic design](https://bradfrost.com/blog/post/atomic-web-design/):

```
widgets/
├── atoms/       # DateTimeField, ReadOnlyField, HealthFormSectionLabel, shared form validators
├── molecules/   # DataTypeChipField, DataCollectorPickerField, ValueInputRow
└── organisms/   # HealthFormSheet (the bottom-sheet scaffold every write form is built on)
```

`ValueInputRow<T>` is the one worth calling out: it's a generic field-name/type/value row, parameterized over the value's "kind" enum, used identically by the insert-health-record form (`integer | long | string`) and the upload-sample-data form (`integer | float | string`) — before this it was two nearly-identical hand-rolled widgets.

Page-specific composition (cards, info rows, layout for one particular screen) stays local to that screen's file rather than being promoted to a shared folder — only genuinely cross-cutting pieces live in `widgets/`.

## Folder structure

```
lib/
├── main.dart                          # loads .env, wraps the app in ProviderScope
├── core/
│   ├── app_constants.dart             # typed accessors over .env values
│   ├── constants/
│   │   └── health_form_defaults.dart  # example/default values used to prefill dev forms
│   ├── model/                         # domain models (HealthDataType, DetailRecordEntry)
│   ├── navigation/                    # auto_route config + generated routes
│   ├── network/
│   │   ├── service.dart               # AuthService, HealthKitService, HealthKitApiException
│   │   └── model/                     # raw API request/response models
│   ├── service/
│   │   └── health_providers.dart      # Riverpod providers wrapping the services
│   └── theme.dart
└── feature/
    ├── health/
    │   ├── notifier/                  # one AsyncNotifier per use case (see table above)
    │   ├── util/nanoseconds.dart
    │   └── view/
    │       ├── *_sheet.dart           # create/update/insert/upload forms
    │       ├── data_collector_detail_view.dart
    │       ├── add_data_menu_sheet.dart
    │       └── widgets/               # atoms / molecules / organisms
    ├── home/view/home_view.dart       # data collector list, entry point after login
    ├── login/view/                    # login screen + OAuth WebView
    └── splash/view/splash_view.dart   # session check → home or login
```

## Setup

1. Install dependencies:
   ```sh
   flutter pub get
   ```
2. Copy the environment template and fill in your own Huawei Health Kit credentials:
   ```sh
   cp .env.example .env
   ```
   `.env` is gitignored — never commit real credentials. See `.env.example` for the required keys (`CLIENT_ID`, `CLIENT_SECRET`, `AUTH_URL`, `TOKEN_URL`, `REDIRECT_URL`, `BASE_URL`, `WAF_COOKIE`).
3. Run code generation for routing (needed whenever a `@RoutePage()` is added or changed):
   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```sh
   flutter run
   ```

## Tech stack

Flutter · [Riverpod](https://riverpod.dev) (state management) · [auto_route](https://pub.dev/packages/auto_route) (navigation/codegen) · [Dio](https://pub.dev/packages/dio) (HTTP) · [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (token storage) · [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (environment config)

## License

This app is distributed under the terms of the MIT License.
See the [LICENSE](./LICENSE). for more information.
