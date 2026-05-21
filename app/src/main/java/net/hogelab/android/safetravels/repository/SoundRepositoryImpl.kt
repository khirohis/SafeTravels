package net.hogelab.android.safetravels.repository

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.hogelab.android.safetravels.model.SoundStatus
import kotlin.math.PI
import kotlin.math.sin

class SoundRepositoryImpl : SoundRepository {
    private val _status = MutableStateFlow(SoundStatus())
    override val status: StateFlow<SoundStatus> = _status.asStateFlow()

    private var audioTrack: AudioTrack? = null
    private var playbackJob: Job? = null
    private var timerJob: Job? = null
    private val repositoryScope = CoroutineScope(Dispatchers.Default + SupervisorJob())

    private val sampleRate = 44100
    private val bufferSize = AudioTrack.getMinBufferSize(
        sampleRate,
        AudioFormat.CHANNEL_OUT_MONO,
        AudioFormat.ENCODING_PCM_16BIT
    )

    override fun play(frequency: Int, durationSeconds: Int) {
        stop() // Stop any current playback

        _status.value = SoundStatus(
            isPlaying = true,
            frequency = frequency,
            duration = durationSeconds,
            remainingTime = durationSeconds
        )

        playbackJob = repositoryScope.launch {
            startAudioTrack(frequency)
        }

        timerJob = repositoryScope.launch {
            startTimer(durationSeconds)
        }
    }

    override fun stop() {
        playbackJob?.cancel()
        timerJob?.cancel()
        
        audioTrack?.let {
            try {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.stop()
                }
                it.release()
            } catch (e: Exception) {
                // Ignore
            }
        }
        audioTrack = null
        _status.value = _status.value.copy(isPlaying = false, remainingTime = 0)
    }

    private suspend fun startAudioTrack(frequency: Int) {
        audioTrack = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()

        val audioData = ShortArray(bufferSize)
        var phase = 0.0
        val phaseIncrement = 2.0 * PI * frequency / sampleRate

        audioTrack?.play()

        try {
            while (currentCoroutineContext().isActive) {
                for (i in audioData.indices) {
                    audioData[i] = (sin(phase) * Short.MAX_VALUE).toInt().toShort()
                    phase += phaseIncrement
                    if (phase >= 2.0 * PI) phase -= 2.0 * PI
                }
                audioTrack?.write(audioData, 0, audioData.size)
                yield() // Cooperate with cancellation
            }
        } finally {
            withContext(NonCancellable) {
                audioTrack?.stop()
                audioTrack?.release()
                audioTrack = null
            }
        }
    }

    private suspend fun startTimer(durationSeconds: Int) {
        var remaining = durationSeconds
        while (remaining > 0 && currentCoroutineContext().isActive) {
            delay(1000)
            remaining--
            _status.value = _status.value.copy(remainingTime = remaining)
        }
        if (currentCoroutineContext().isActive) {
            stop() // Auto-stop when time is up
        }
    }
}
