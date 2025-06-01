package com.wireless_doorbell_app.astu // Updated package name

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine // Added import
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL_ID = "doorbell_channel" // IMPORTANT: This must match the channel ID in your Flutter code!
    private val CHANNEL_NAME = "Doorbell Alerts" // Added
    private val CHANNEL_DESCRIPTION = "Notifications for smart doorbell rings" // Added

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) { // Added method
        super.configureFlutterEngine(flutterEngine)
        // Ensure that the notification channel is created when the app starts
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Updated channel name, description and importance
            val importance = NotificationManager.IMPORTANCE_HIGH // Matches Flutter's Importance.max
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = CHANNEL_DESCRIPTION
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
