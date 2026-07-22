package com.example.flutter_flight_widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.Intent
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * FlightWidgetProvider — Android AppWidgetProvider for the flight price widget.
 *
 * This class is called by the Android OS whenever the widget needs to be
 * redrawn (on boot, after [HomeWidget.updateWidget] is called from Flutter,
 * or when the user adds the widget to their home screen).
 *
 * Data flow:
 *   Flutter (FlightProvider) → HomeWidget.saveWidgetData()
 *     → stores values in SharedPreferences under the App Group
 *   Flutter → HomeWidget.updateWidget()
 *     → sends ACTION_APPWIDGET_UPDATE broadcast to this class
 *   onUpdate() → reads saved values → builds RemoteViews → pushes to OS
 */
class FlightWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Retrieve data saved by Flutter via HomeWidget.saveWidgetData().
        // HomeWidgetPlugin.getData() returns a SharedPreferences instance
        // backed by the same file that the Flutter plugin writes to.
        val widgetData = HomeWidgetPlugin.getData(context)

        val route   = widgetData.getString("widget_route",   "No flight selected") ?: "No flight selected"
        val price   = widgetData.getString("widget_price",   "---")                 ?: "---"
        val date    = widgetData.getString("widget_date",    "---")                 ?: "---"
        val updated = widgetData.getString("widget_updated", "")                    ?: ""

        // Build the RemoteViews from our layout XML and populate each TextView.
        val views = RemoteViews(context.packageName, R.layout.flight_widget_layout)
        views.setTextViewText(R.id.widget_route,   route)
        views.setTextViewText(R.id.widget_price,   price)
        views.setTextViewText(R.id.widget_date,    date)
        views.setTextViewText(R.id.widget_updated, if (updated.isNotEmpty()) "Updated $updated" else "")

        // Tapping the widget launches the main Flutter activity.
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_route, pendingIntent)
        views.setOnClickPendingIntent(R.id.widget_price, pendingIntent)

        // Push the updated views to every widget instance on the home screen.
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
