package net.hogelab.android.safetravels.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import net.hogelab.android.safetravels.MainActivity
import net.hogelab.android.safetravels.R
import net.hogelab.android.safetravels.repository.SoundRepository
import javax.inject.Inject

@AndroidEntryPoint
class SoundForegroundService : Service() {

    companion object {
        const val ACTION_START = "ACTION_START"
        const val ACTION_PAUSE = "ACTION_PAUSE"
        const val ACTION_RESUME = "ACTION_RESUME"
        const val ACTION_STOP = "ACTION_STOP"
    }

    private val CHANNEL_ID = "SoundServiceChannel"
    private val NOTIFICATION_ID = 1

    @Inject
    lateinit var soundRepository: SoundRepository

    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    inner class LocalBinder : Binder() {
        fun getService(): SoundForegroundService = this@SoundForegroundService
    }

    private val binder = LocalBinder()

    override fun onCreate() {
        super.onCreate()
        observeSoundStatus()
    }

    private fun observeSoundStatus() {
        soundRepository.status
            .onEach { status ->
                if (status.isPlaying || status.isPaused) {
                    val notification = createNotification()
                    val manager = getSystemService(NotificationManager::class.java)
                    manager.notify(NOTIFICATION_ID, notification)
                } else {
                    stopSelf()
                }
            }
            .launchIn(serviceScope)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        
        when (intent?.action) {
            ACTION_START -> {
                val frequency = intent.getIntExtra("frequency", 0)
                val duration = intent.getIntExtra("duration", 0)
                if (frequency > 0 && duration > 0) {
                    val notification = createNotification()
                    startForeground(NOTIFICATION_ID, notification)
                    soundRepository.play(frequency, duration)
                }
            }
            ACTION_PAUSE -> {
                soundRepository.pause()
            }
            ACTION_RESUME -> {
                soundRepository.resume()
            }
            ACTION_STOP -> {
                soundRepository.stop()
                stopSelf()
            }
            else -> {
                // Fallback for old intent style or no action
                val frequency = intent?.getIntExtra("frequency", 0) ?: 0
                val duration = intent?.getIntExtra("duration", 0) ?: 0
                if (frequency > 0 && duration > 0) {
                    val notification = createNotification()
                    startForeground(NOTIFICATION_ID, notification)
                    soundRepository.play(frequency, duration)
                } else {
                    stopSelf()
                }
            }
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return binder
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
        soundRepository.stop()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                getString(R.string.notification_channel_name),
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        val status = soundRepository.status.value
        val isPaused = status.isPaused

        val mainIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val mainPendingIntent = PendingIntent.getActivity(
            this, 0, mainIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val pauseResumeAction = if (isPaused) {
            val resumeIntent = Intent(this, SoundForegroundService::class.java).apply {
                action = ACTION_RESUME
            }
            val resumePendingIntent = PendingIntent.getService(
                this, 1, resumeIntent, PendingIntent.FLAG_IMMUTABLE
            )
            NotificationCompat.Action(
                android.R.drawable.ic_media_play,
                getString(R.string.content_desc_resume),
                resumePendingIntent
            )
        } else {
            val pauseIntent = Intent(this, SoundForegroundService::class.java).apply {
                action = ACTION_PAUSE
            }
            val pausePendingIntent = PendingIntent.getService(
                this, 2, pauseIntent, PendingIntent.FLAG_IMMUTABLE
            )
            NotificationCompat.Action(
                android.R.drawable.ic_media_pause,
                getString(R.string.content_desc_pause),
                pausePendingIntent
            )
        }

        val stopIntent = Intent(this, SoundForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 3, stopIntent, PendingIntent.FLAG_IMMUTABLE
        )
        val stopAction = NotificationCompat.Action(
            android.R.drawable.ic_menu_close_clear_cancel,
            getString(R.string.content_desc_stop),
            stopPendingIntent
        )

        val contentText = if (isPaused) {
            getString(R.string.notification_content_paused)
        } else {
            getString(R.string.notification_content)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.notification_title))
            .setContentText(contentText)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(mainPendingIntent)
            .setOngoing(!isPaused)
            .addAction(pauseResumeAction)
            .addAction(stopAction)
            .setStyle(androidx.media.app.NotificationCompat.MediaStyle()
                .setShowActionsInCompactView(0, 1))
            .build()
    }
}
