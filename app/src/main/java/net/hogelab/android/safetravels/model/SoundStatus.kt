package net.hogelab.android.safetravels.model

data class SoundStatus(
    val isPlaying: Boolean = false,
    val isPaused: Boolean = false,
    val frequency: Int = 0,
    val duration: Int = 0,
    val remainingTime: Int = 0
)
