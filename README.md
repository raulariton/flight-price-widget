# Flutter Flight Widget

A Flutter prototype that displays real-time flight prices on home screen widgets for **Android** and **iOS** using the [`home_widget`](https://pub.dev/packages/home_widget) package.

## Features

- Track 4 sample flights (hardcoded data for prototype)
- Currency selector: USD, EUR, GBP, CAD (fixed mock rates)
- Home screen widget shows route, departure date, and price at a glance
- Widget updates instantly when you change the selected flight or currency
- Manual refresh button in Settings
- Material 3 design with a dark-blue theme

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, Provider setup
├── data/
│   └── sample_flights.dart      # Hardcoded prototype flights
├── models/
│   ├── flight.dart              # Flight data model
│   └── currency.dart            # Currency enum with conversion rates
├── providers/
│   └── flight_provider.dart     # ChangeNotifier — state + widget update logic
└── screens/
    ├── home_screen.dart         # Flight list + widget preview card
    └── settings_screen.dart     # Currency picker + manual refresh

android/app/src/main/
├── kotlin/com/example/flutter_flight_widget/
│   └── FlightWidgetProvider.kt  # AppWidgetProvider — reads SharedPrefs, builds RemoteViews
└── res/
    ├── layout/flight_widget_layout.xml  # Widget layout XML
    ├── xml/flight_widget_info.xml       # Widget metadata (size, update policy)
    └── drawable/widget_background.xml  # Rounded-rect blue background

ios/
└── FlightWidgetExtension/
    ├── FlightWidget.swift        # WidgetKit timeline provider + SwiftUI view
    └── Info.plist                # Extension metadata
```

---

## Setup

### Prerequisites

- Flutter 3.x (tested with 3.44.6)
- Xcode 15+ (for WidgetKit/iOS 17 APIs)
- Android Studio or VS Code with Flutter plugin
- A physical device or simulator/emulator for widget testing

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Android Setup

The Android widget is mostly ready to go from source. Verify:

1. **AndroidManifest.xml** already contains the `<receiver>` block for `FlightWidgetProvider`.
2. Build and run on an Android device/emulator:
   ```bash
   flutter run
   ```
3. Long-press the home screen → **Widgets** → search "Flight" → drag to home screen.

### 3. iOS Setup (requires Xcode)

The WidgetKit extension must be added to the Xcode project manually because Flutter's build system does not auto-create extension targets:

#### Step-by-step in Xcode

1. Open the Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add the widget extension target:**
   - File → New → Target → **Widget Extension**
   - Product Name: `FlightWidgetExtension`
   - Bundle Identifier: `com.example.flutterFlightWidget.FlightWidgetExtension`
   - ✅ Include Configuration Intent: **No** (we use `StaticConfiguration`)
   - Click Finish → **Do NOT activate the new scheme** (keep Runner selected)

3. **Replace the generated Swift file** with the one already in the repo:
   - In Xcode's Project Navigator, inside `FlightWidgetExtension/`, delete the auto-generated `.swift` file
   - Right-click the folder → **Add Files to Runner** → select `ios/FlightWidgetExtension/FlightWidget.swift`

4. **Configure App Group** (critical — this is the shared container Flutter writes to):
   - Select the **Runner** target → **Signing & Capabilities** → **+ Capability** → App Groups
   - Add: `group.com.example.flutterFlightWidget`
   - Select the **FlightWidgetExtension** target → repeat, adding the same App Group

5. **Build and run:**
   ```bash
   flutter run
   ```
   Then add the widget from the iOS widget gallery (long-press home screen → tap **+**).

---

## Widget Data Flow

```
Flutter app
   │
   ├── User selects flight / changes currency
   │
   ▼
FlightProvider._updateWidget()
   │
   ├── HomeWidget.saveWidgetData("widget_route",   "SFO → JFK")
   ├── HomeWidget.saveWidgetData("widget_price",   "$289.00")
   ├── HomeWidget.saveWidgetData("widget_date",    "Sep 15, 2025")
   └── HomeWidget.saveWidgetData("widget_updated", "2:30 PM")
         │
         ▼  (writes to App Group UserDefaults / SharedPreferences)
         │
   HomeWidget.updateWidget(
     qualifiedAndroidName: "...FlightWidgetProvider",
     iOSName: "FlightWidget"
   )
         │
   ┌─────┴──────────────────┐
   │                        │
Android                    iOS
FlightWidgetProvider.kt    FlightProvider.getTimeline()
reads SharedPrefs          reads UserDefaults(suiteName:)
builds RemoteViews         builds SwiftUI view
```

---

## Key Integration Points

| File | What it does |
|---|---|
| [`lib/providers/flight_provider.dart`](lib/providers/flight_provider.dart) | Calls `HomeWidget.saveWidgetData` + `HomeWidget.updateWidget` |
| [`android/.../FlightWidgetProvider.kt`](android/app/src/main/kotlin/com/example/flutter_flight_widget/FlightWidgetProvider.kt) | `AppWidgetProvider.onUpdate()` reads saved data and builds `RemoteViews` |
| [`android/.../AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) | Registers the `<receiver>` with `APPWIDGET_UPDATE` intent filter |
| [`ios/FlightWidgetExtension/FlightWidget.swift`](ios/FlightWidgetExtension/FlightWidget.swift) | WidgetKit `TimelineProvider` reads `UserDefaults(suiteName:)` and returns a `Timeline` |
| [`android/.../res/xml/flight_widget_info.xml`](android/app/src/main/res/xml/flight_widget_info.xml) | Widget metadata: min size, update policy |
| [`android/.../res/layout/flight_widget_layout.xml`](android/app/src/main/res/layout/flight_widget_layout.xml) | Widget UI layout (RemoteViews-compatible) |

### App Group ID

Both sides share one constant:

```
group.com.example.flutterFlightWidget
```

- **Flutter** — set via `HomeWidget.setAppGroupId(...)` in `FlightProvider._init()`
- **iOS** — `UserDefaults(suiteName: kAppGroup)` in `FlightWidget.swift`
- **Android** — handled automatically by the `home_widget` plugin's `HomeWidgetPlugin.getData(context)`

---

## Testing the Widget

### Android

1. Run on device / emulator with `flutter run`
2. Select a flight in the app
3. Long-press home screen → Widgets → "Flight Price Widget"
4. Confirm price and route appear
5. Change currency in Settings → confirm widget updates

### iOS (Simulator)

1. Run on iOS Simulator via Xcode (widget extensions only run in simulators / devices after step 3 above is complete)
2. Home screen long-press → tap **+** top-left → search "Flight"
3. Choose size (Small or Medium) → Add Widget
4. Return to app, select a different flight → widget should refresh immediately

### Manual refresh

If the widget appears stale, go to Settings screen inside the app and tap **"Refresh widget now"**.

---

## Mock Data

Four hardcoded flights in [`lib/data/sample_flights.dart`](lib/data/sample_flights.dart):

| Route | Airline | Price (USD) | Date |
|---|---|---|---|
| SFO → JFK | United Airlines | $289.00 | Sep 15, 2025 |
| LAX → LHR | British Airways | $621.50 | Oct 3, 2025 |
| ORD → CDG | Air France | $545.00 | Nov 20, 2025 |
| MIA → CUN | American Airlines | $174.99 | Aug 28, 2025 |

### Mock currency rates

| Currency | Rate vs USD |
|---|---|
| USD | 1.00 |
| EUR | 0.92 |
| GBP | 0.79 |
| CAD | 1.37 |

---

## Out of Scope (Prototype)

- Real flight price API
- Background price polling
- Push notifications
- Multiple widget instances
- Email / calendar parsing
- Authentication

---

## License

MIT
