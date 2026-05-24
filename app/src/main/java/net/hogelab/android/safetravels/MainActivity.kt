package net.hogelab.android.safetravels

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedIconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.hogelab.android.safetravels.model.SoundStatus
import net.hogelab.android.safetravels.ui.theme.SafeTravelsTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SafeTravelsTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    val duration by viewModel.duration.collectAsState()
                    val soundStatus by viewModel.soundStatus.collectAsState()

                    SoundControlPanel(
                        duration = duration,
                        soundStatus = soundStatus,
                        onDurationChange = viewModel::updateDuration,
                        onTogglePlayback = viewModel::togglePlayback,
                        onStopPlayback = viewModel::stopPlayback,
                        modifier = Modifier.padding(innerPadding),
                    )
                }
            }
        }
    }
}

@Composable
fun SoundControlPanel(
    duration: Float,
    soundStatus: SoundStatus,
    onDurationChange: (Float) -> Unit,
    onTogglePlayback: () -> Unit,
    onStopPlayback: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isActive = soundStatus.isPlaying || soundStatus.isPaused
    val isPaused = soundStatus.isPaused
    val isActuallyPlaying = soundStatus.isPlaying && !isPaused

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(32.dp, Alignment.CenterVertically)
    ) {
        // Frequency Display (Fixed)
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = stringResource(R.string.label_frequency),
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.secondary
            )
            Text(
                text = "100 ${stringResource(R.string.unit_hz)}",
                style = MaterialTheme.typography.displayLarge,
                color = MaterialTheme.colorScheme.primary
            )
        }

        // Duration Control
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = stringResource(R.string.label_duration),
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.secondary
            )
            Text(
                text = "${duration.toInt()} ${stringResource(R.string.unit_sec)}",
                style = MaterialTheme.typography.displayMedium,
                color = MaterialTheme.colorScheme.primary
            )
            Slider(
                value = duration,
                onValueChange = onDurationChange,
                valueRange = 1f..180f,
                modifier = Modifier.padding(horizontal = 16.dp),
                enabled = !isActive
            )
            Text(
                text = stringResource(R.string.label_range_duration),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.outline
            )
        }

        // Playback Status (Remaining Time)
        if (isActive) {
            Text(
                text = stringResource(R.string.format_remaining, soundStatus.remainingTime),
                style = MaterialTheme.typography.headlineSmall,
                color = if (isPaused) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.tertiary
            )
        } else {
            Spacer(modifier = Modifier.height(32.dp))
        }

        // Playback Controls
        Row(
            horizontalArrangement = Arrangement.spacedBy(24.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Play/Pause Button
            FilledIconButton(
                onClick = onTogglePlayback,
                modifier = Modifier.size(80.dp),
                shape = CircleShape,
                colors = IconButtonDefaults.filledIconButtonColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = Color.White
                )
            ) {
                Icon(
                    imageVector = if (isActuallyPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = if (isActuallyPlaying) {
                        stringResource(R.string.content_desc_pause)
                    } else if (isPaused) {
                        stringResource(R.string.content_desc_resume)
                    } else {
                        stringResource(R.string.content_desc_start)
                    },
                    modifier = Modifier.size(40.dp)
                )
            }

            // Stop Button
            OutlinedIconButton(
                onClick = onStopPlayback,
                modifier = Modifier.size(80.dp),
                shape = CircleShape,
                enabled = isActive,
                colors = IconButtonDefaults.outlinedIconButtonColors(
                    contentColor = MaterialTheme.colorScheme.error
                )
            ) {
                Icon(
                    imageVector = Icons.Default.Stop,
                    contentDescription = stringResource(R.string.content_desc_stop),
                    modifier = Modifier.size(40.dp)
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SoundControlPanelPreview() {
    SafeTravelsTheme {
        SoundControlPanel(
            duration = 60f,
            soundStatus = SoundStatus(isPlaying = false),
            onDurationChange = {},
            onTogglePlayback = {},
            onStopPlayback = {}
        )
    }
}
