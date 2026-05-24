package net.hogelab.android.safetravels.repository

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.hogelab.android.safetravels.model.SoundStatus
import javax.inject.Inject
import kotlin.math.PI
import kotlin.math.sin

class SoundRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context
) : SoundRepository {
    private val _status = MutableStateFlow(SoundStatus())
    override val status: StateFlow<SoundStatus> = _status.asStateFlow()

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var audioTrack: AudioTrack? = null
    private var playbackJob: Job? = null
    private var timerJob: Job? = null
    private val repositoryScope = CoroutineScope(Dispatchers.Default + SupervisorJob())

    private val focusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        when (focusChange) {
            AudioManager.AUDIOFOCUS_LOSS,
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                stop()
            }
        }
    }

    private val audioAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build()

    private val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
        .setAudioAttributes(audioAttributes)
        .setAcceptsDelayedFocusGain(false)
        .setOnAudioFocusChangeListener(focusChangeListener)
        .build()

    private val sampleRate = 44100
    private val bufferSize = AudioTrack.getMinBufferSize(
        sampleRate,
        AudioFormat.CHANNEL_OUT_MONO,
        AudioFormat.ENCODING_PCM_16BIT
    )

    override fun play(frequency: Int, durationSeconds: Int) {
        val result = audioManager.requestAudioFocus(focusRequest)
        if (result != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            return
        }

        stopPlayback() // Stop any current playback jobs without abandoning focus

        _status.value = SoundStatus(
            isPlaying = true,
            isPaused = false,
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

    override fun pause() {
        if (!_status.value.isPlaying || _status.value.isPaused) return

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
        _status.value = _status.value.copy(isPlaying = true, isPaused = true)
    }

    override fun resume() {
        val status = _status.value
        if (!status.isPlaying || !status.isPaused) return

        val result = audioManager.requestAudioFocus(focusRequest)
        if (result != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            return
        }

        _status.value = status.copy(isPaused = false)

        playbackJob = repositoryScope.launch {
            startAudioTrack(status.frequency)
        }

        timerJob = repositoryScope.launch {
            startTimer(status.remainingTime)
        }
    }

    override fun stop() {
        audioManager.abandonAudioFocusRequest(focusRequest)
        stopPlayback()
    }

    private fun stopPlayback() {
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
        _status.value = SoundStatus() // Reset all
    }

    private suspend fun startAudioTrack(frequency: Int) {
        audioTrack = AudioTrack.Builder()
            .setAudioAttributes(audioAttributes)
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
                try {
                    audioTrack?.let {
                        if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                            it.stop()
                        }
                        it.release()
                    }
                } catch (e: Exception) {
                    // Ignore already released or invalid state exceptions
                }
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
