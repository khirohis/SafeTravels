package net.hogelab.android.safetravels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.hogelab.android.safetravels.model.SoundStatus
import net.hogelab.android.safetravels.repository.SoundRepository
import net.hogelab.android.safetravels.repository.SoundRepositoryImpl

class MainViewModel(
    private val repository: SoundRepository = SoundRepositoryImpl()
) : ViewModel() {

    private val _frequency = MutableStateFlow(440f)
    val frequency: StateFlow<Float> = _frequency.asStateFlow()

    private val _duration = MutableStateFlow(60f)
    val duration: StateFlow<Float> = _duration.asStateFlow()

    // Expose repository status to the UI
    val soundStatus: StateFlow<SoundStatus> = repository.status

    fun updateFrequency(value: Float) {
        _frequency.value = value
    }

    fun updateDuration(value: Float) {
        _duration.value = value
    }

    fun togglePlayback() {
        if (soundStatus.value.isPlaying) {
            repository.stop()
        } else {
            repository.play(
                frequency = _frequency.value.toInt(),
                durationSeconds = _duration.value.toInt()
            )
        }
    }

    override fun onCleared() {
        super.onCleared()
        repository.stop()
    }
}
