import 'package:flutter/material.dart';
import '../view_models/main_view_model.dart';

class HomeScreen extends StatelessWidget {
  final MainViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (!viewModel.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isPlaying = viewModel.status.isPlaying;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FrequencyControl(
                    frequency: viewModel.frequency,
                    isPlaying: isPlaying,
                    onChanged: viewModel.updateFrequency,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 40),
                  _DurationControl(
                    duration: viewModel.duration,
                    isPlaying: isPlaying,
                    onChanged: viewModel.updateDuration,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 40,
                    child: isPlaying
                        ? Text(
                            '残り ${viewModel.status.remainingTime} 秒',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.tertiary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 32),
                  _PlayStopButton(
                    isPlaying: isPlaying,
                    onPressed: viewModel.togglePlayback,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FrequencyControl extends StatelessWidget {
  final double frequency;
  final bool isPlaying;
  final ValueChanged<double> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _FrequencyControl({
    required this.frequency,
    required this.isPlaying,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Frequency',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary),
        ),
        Text(
          '${frequency.toInt()} Hz',
          style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
        ),
        Slider(
          value: frequency,
          min: 40,
          max: 20000,
          onChanged: isPlaying ? null : onChanged,
        ),
        Text(
          '範囲: 40Hz - 20kHz',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
      ],
    );
  }
}

class _DurationControl extends StatelessWidget {
  final double duration;
  final bool isPlaying;
  final ValueChanged<double> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _DurationControl({
    required this.duration,
    required this.isPlaying,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Duration',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary),
        ),
        Text(
          '${duration.toInt()} 秒',
          style: textTheme.displayMedium?.copyWith(color: colorScheme.primary),
        ),
        Slider(
          value: duration,
          min: 1,
          max: 3600,
          onChanged: isPlaying ? null : onChanged,
        ),
        Text(
          '範囲: 1秒 - 3600秒',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
      ],
    );
  }
}

class _PlayStopButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _PlayStopButton({
    required this.isPlaying,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor:
              isPlaying ? colorScheme.error : colorScheme.primary,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Icon(
          isPlaying ? Icons.stop : Icons.play_arrow,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }
}
