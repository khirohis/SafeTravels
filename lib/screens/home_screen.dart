import 'dart:math';

import 'package:flutter/material.dart';
import '../view_models/main_view_model.dart';

const double _freqMin = 40.0;
const double _freqMax = 20000.0;
const double _durMin = 1.0;
const double _durMax = 3600.0;

double _freqToSlider(double freq) =>
    log(freq / _freqMin) / log(_freqMax / _freqMin);

double _sliderToFreq(double t) =>
    _freqMin * pow(_freqMax / _freqMin, t).toDouble();

double _durToSlider(double dur) =>
    log(dur / _durMin) / log(_durMax / _durMin);

double _sliderToDur(double t) =>
    (_durMin * pow(_durMax / _durMin, t)).clamp(_durMin, _durMax);

String _formatDuration(double seconds) {
  final s = seconds.toInt();
  if (s < 60) return '$s 秒';
  if (s < 3600) return '${s ~/ 60} 分 ${s % 60} 秒';
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  return m == 0 ? '$h 時間' : '$h 時間 $m 分';
}

String _formatRemaining(int seconds) {
  if (seconds < 60) return '残り $seconds 秒';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (seconds < 3600) return '残り $m:${s.toString().padLeft(2, '0')}';
  final h = seconds ~/ 3600;
  final m2 = (seconds % 3600) ~/ 60;
  final s2 = seconds % 60;
  return '残り $h:${m2.toString().padLeft(2, '0')}:${s2.toString().padLeft(2, '0')}';
}

String _formatFrequency(double freq) {
  if (freq >= 1000) {
    final khz = freq / 1000;
    return '${khz % 1 == 0 ? khz.toInt() : khz.toStringAsFixed(1)} kHz';
  }
  return '${freq.toInt()} Hz';
}

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
                  _PlaybackProgress(
                    isPlaying: isPlaying,
                    remainingTime: viewModel.status.remainingTime,
                    totalDuration: viewModel.duration.toInt(),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
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
          '周波数',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary),
        ),
        Text(
          _formatFrequency(frequency),
          style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
        ),
        Slider(
          value: _freqToSlider(frequency),
          min: 0,
          max: 1,
          onChanged: isPlaying ? null : (t) => onChanged(_sliderToFreq(t)),
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
          '再生時間',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary),
        ),
        Text(
          _formatDuration(duration),
          style: textTheme.displayMedium?.copyWith(color: colorScheme.primary),
        ),
        Slider(
          value: _durToSlider(duration),
          min: 0,
          max: 1,
          onChanged: isPlaying ? null : (t) => onChanged(_sliderToDur(t)),
        ),
        Text(
          '範囲: 1秒 - 1時間',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
      ],
    );
  }
}

class _PlaybackProgress extends StatelessWidget {
  final bool isPlaying;
  final int remainingTime;
  final int totalDuration;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PlaybackProgress({
    required this.isPlaying,
    required this.remainingTime,
    required this.totalDuration,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) return const SizedBox(height: 56);

    final progress = totalDuration > 0
        ? 1 - remainingTime / totalDuration
        : 0.0;

    return SizedBox(
      height: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          Text(
            _formatRemaining(remainingTime),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
          ),
        ],
      ),
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
          backgroundColor: isPlaying ? colorScheme.error : colorScheme.primary,
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
