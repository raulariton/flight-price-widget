import WidgetKit
import SwiftUI

// MARK: - Data model

/// Mirrors the data written by Flutter's FlightProvider via home_widget.
/// Keys must match the constants in lib/providers/flight_provider.dart.
struct FlightEntry: TimelineEntry {
    let date: Date
    let route: String
    let price: String
    let departureDate: String
    let updatedAt: String
}

// MARK: - UserDefaults key constants (must match Flutter side)

private let kAppGroup   = "group.com.example.flutterFlightWidget"
private let kRoute      = "widget_route"
private let kPrice      = "widget_price"
private let kDate       = "widget_date"
private let kUpdated    = "widget_updated"

// MARK: - Timeline provider

/// Reads data from the shared App Group UserDefaults container
/// (populated by Flutter via home_widget) and provides a single timeline entry.
struct FlightProvider: TimelineProvider {
    /// Placeholder shown while the widget gallery renders a preview.
    func placeholder(in context: Context) -> FlightEntry {
        FlightEntry(
            date: Date(),
            route: "SFO → JFK",
            price: "$289.00",
            departureDate: "Sep 15, 2025",
            updatedAt: "12:00 PM"
        )
    }

    /// Snapshot used in the widget picker.
    func getSnapshot(in context: Context, completion: @escaping (FlightEntry) -> Void) {
        completion(readEntry())
    }

    /// Returns one entry and tells WidgetKit not to schedule automatic refreshes.
    /// The Flutter app triggers refreshes by calling HomeWidget.updateWidget().
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlightEntry>) -> Void) {
        let entry = readEntry()
        // .never means WidgetKit will only reload when explicitly requested
        // (i.e., when Flutter calls WidgetCenter.shared.reloadAllTimelines).
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    // MARK: Private helpers

    private func readEntry() -> FlightEntry {
        let defaults = UserDefaults(suiteName: kAppGroup)
        return FlightEntry(
            date:          Date(),
            route:         defaults?.string(forKey: kRoute)    ?? "No flight selected",
            price:         defaults?.string(forKey: kPrice)    ?? "---",
            departureDate: defaults?.string(forKey: kDate)     ?? "---",
            updatedAt:     defaults?.string(forKey: kUpdated)  ?? ""
        )
    }
}

// MARK: - Widget view

struct FlightWidgetEntryView: View {
    var entry: FlightEntry

    var body: some View {
        ZStack {
            // Background — deep blue to match the Android widget and app theme
            Color(red: 0.082, green: 0.396, blue: 0.753)

            VStack(alignment: .leading, spacing: 4) {
                // Header label
                Label("Flight Tracker", systemImage: "airplane")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .labelStyle(.titleAndIcon)

                Spacer().frame(height: 4)

                // Route
                Text(entry.route)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Departure date
                Text(entry.departureDate)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                // Price — large and prominent
                Text(entry.price)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)

                // Last updated
                if !entry.updatedAt.isEmpty {
                    Text("Updated \(entry.updatedAt)")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Widget configuration

/// "FlightWidget" must match the iOSName passed to HomeWidget.updateWidget() in Flutter.
@main
struct FlightWidget: Widget {
    let kind: String = "FlightWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FlightProvider()) { entry in
            // Link tap opens the main Flutter app.
            // The URL is handled by onReceive(NotificationCenter...) or
            // can be intercepted via HomeWidget.widgetClicked in Flutter.
            Link(destination: URL(string: "flightwidget://open")!) {
                FlightWidgetEntryView(entry: entry)
            }
            .containerBackground(for: .widget) {
                Color(red: 0.082, green: 0.396, blue: 0.753)
            }
        }
        .configurationDisplayName("Flight Price")
        .description("Track your selected flight price at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    FlightWidget()
} timeline: {
    FlightEntry(
        date: .now,
        route: "SFO → JFK",
        price: "$289.00",
        departureDate: "Sep 15, 2025",
        updatedAt: "2:30 PM"
    )
}
