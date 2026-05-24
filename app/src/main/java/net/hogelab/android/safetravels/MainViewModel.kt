package net.hogelab.android.safetravels

import android.content.Context
import android.content.Intent
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.hogelab.android.safetravels.model.SoundStatus
import net.hogelab.android.safetravels.repository.SoundRepository
import net.hogelab.android.safetravels.service.SoundForegroundService
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val repository: SoundRepository,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val fixedFrequency = 100

    private val _duration = MutableStateFlow(60f)
    val duration: StateFlow<Float> = _duration.asStateFlow()

    // Expose repository status to the UI
    val soundStatus: StateFlow<SoundStatus> = repository.status

    fun updateDuration(value: Float) {
        _duration.value = value
    }

    fun togglePlayback() {
        val status = soundStatus.value
        if (status.isPaused) {
            val intent = Intent(context, SoundForegroundService::class.java).apply {
                action = SoundForegroundService.ACTION_RESUME
            }
            context.startForegroundService(intent)
        } else if (status.isPlaying) {
            val intent = Intent(context, SoundForegroundService::class.java).apply {
                action = SoundForegroundService.ACTION_PAUSE
            }
            context.startForegroundService(intent)
        } else {
            val intent = Intent(context, SoundForegroundService::class.java).apply {
                action = SoundForegroundService.ACTION_START
                putExtra("frequency", fixedFrequency)
                putExtra("duration", _duration.value.toInt())
            }
            context.startForegroundService(intent)
        }
    }

    fun stopPlayback() {
        val intent = Intent(context, SoundForegroundService::class.java).apply {
            action = SoundForegroundService.ACTION_STOP
        }
        context.startForegroundService(intent)
    }

    override fun onCleared() {
        super.onCleared()
    }
}
