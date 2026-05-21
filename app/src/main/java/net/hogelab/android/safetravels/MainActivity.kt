package net.hogelab.android.safetravels

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import net.hogelab.android.safetravels.ui.theme.SafeTravelsTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SafeTravelsTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    val viewModel: MainViewModel = viewModel()
                    SoundControlPanel(
                        viewModel = viewModel,
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun SoundControlPanel(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val frequency by viewModel.frequency.collectAsState()
    val duration by viewModel.duration.collectAsState()
    val soundStatus by viewModel.soundStatus.collectAsState()

    val isPlaying = soundStatus.isPlaying

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(32.dp, Alignment.CenterVertically)
    ) {
        // Frequency Control
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "Frequency",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.secondary
            )
            Text(
                text = "${frequency.toInt()} Hz",
                style = MaterialTheme.typography.displayLarge,
                color = MaterialTheme.colorScheme.primary
            )
            Slider(
                value = frequency,
                onValueChange = { viewModel.updateFrequency(it) },
                valueRange = 100f..20000f,
                modifier = Modifier.padding(horizontal = 16.dp),
                enabled = !isPlaying
            )
            Text(
                text = "Range: 100Hz - 20kHz",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.outline
            )
        }

        // Duration Control
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "Duration",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.secondary
            )
            Text(
                text = "${duration.toInt()} sec",
                style = MaterialTheme.typography.displayMedium,
                color = MaterialTheme.colorScheme.primary
            )
            Slider(
                value = duration,
                onValueChange = { viewModel.updateDuration(it) },
                valueRange = 1f..180f,
                modifier = Modifier.padding(horizontal = 16.dp),
                enabled = !isPlaying
            )
            Text(
                text = "Range: 1s - 180s",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.outline
            )
        }

        // Playback Status (Remaining Time)
        if (isPlaying) {
            Text(
                text = "Remaining: ${soundStatus.remainingTime}s",
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.tertiary
            )
        } else {
            Spacer(modifier = Modifier.height(32.dp))
        }

        // Large Circular Control Button
        FilledIconButton(
            onClick = { viewModel.togglePlayback() },
            modifier = Modifier.size(100.dp),
            shape = CircleShape,
            colors = IconButtonDefaults.filledIconButtonColors(
                containerColor = if (isPlaying) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary,
                contentColor = Color.White
            )
        ) {
            Icon(
                imageVector = if (isPlaying) Icons.Default.Stop else Icons.Default.PlayArrow,
                contentDescription = if (isPlaying) "Stop" else "Start",
                modifier = Modifier.size(48.dp)
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SoundControlPanelPreview() {
    SafeTravelsTheme {
        SoundControlPanel(viewModel = MainViewModel())
    }
}