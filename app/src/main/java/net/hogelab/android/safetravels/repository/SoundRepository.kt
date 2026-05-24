package net.hogelab.android.safetravels.repository

import kotlinx.coroutines.flow.StateFlow
import net.hogelab.android.safetravels.model.SoundStatus

interface SoundRepository {
    val status: StateFlow<SoundStatus>
    fun play(frequency: Int, durationSeconds: Int)
    fun pause()
    fun resume()
    fun stop()
}
