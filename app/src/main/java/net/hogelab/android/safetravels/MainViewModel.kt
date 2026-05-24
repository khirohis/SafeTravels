package net.hogelab.android.safetravels

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.hogelab.android.safetravels.model.SoundStatus
import net.hogelab.android.safetravels.repository.SoundRepository
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val repository: SoundRepository,
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
        if (soundStatus.value.isPlaying) {
            repository.stop()
        } else {
            repository.play(
                frequency = fixedFrequency,
                durationSeconds = _duration.value.toInt()
            )
        }
    }

    override fun onCleared() {
        super.onCleared()
        repository.stop()
    }
}
