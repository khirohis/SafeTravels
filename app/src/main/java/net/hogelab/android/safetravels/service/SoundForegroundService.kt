package net.hogelab.android.safetravels.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import dagger.hilt.android.AndroidEntryPoint
import net.hogelab.android.safetravels.R
import net.hogelab.android.safetravels.repository.SoundRepository
import javax.inject.Inject

@AndroidEntryPoint
class SoundForegroundService : Service() {

    private val CHANNEL_ID = "SoundServiceChannel"
    private val NOTIFICATION_ID = 1

    @Inject
    lateinit var soundRepository: SoundRepository

    inner class LocalBinder : Binder() {
        fun getService(): SoundForegroundService = this@SoundForegroundService
    }

    private val binder = LocalBinder()

    override fun onCreate() {
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)

        val frequency = intent?.getIntExtra("frequency", 0) ?: 0
        val duration = intent?.getIntExtra("duration", 0) ?: 0

        if (frequency > 0 && duration > 0) {
            soundRepository.play(frequency, duration)
        } else {
            soundRepository.stop()
            stopSelf()
        }

        // START_NOT_RESTARTABLE (2) を返すことで、意図しない再スタートを防止し、
        // unbind 後に Sound が再生されていない場合は速やかに終了されるようにします。
        return 2
    }

    override fun onBind(intent: Intent?): IBinder? {
        return binder
    }

    override fun onDestroy() {
        super.onDestroy()
        soundRepository.stop()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Sound Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SafeTravels Sound Service")
            .setContentText("Playing sound...")
            .setSmallIcon(R.drawable.ic_launcher_foreground) // 適切なアイコンを設定してください
            .build()
    }
}