import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_preset.dart';
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
        final isLoop = viewModel.isLoop;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        Future<void> onPresetSelected(SoundPreset preset) async {
          viewModel.selectPreset(preset);
          if (preset.warning != null) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(preset.warning!),
                duration: const Duration(seconds: 4),
              ),
            );
          }
          if (preset.requiresDisclaimer) {
            final prefs = await SharedPreferences.getInstance();
            final key = 'disclaimer_${preset.id}';
            if (prefs.getBool(key) != true) {
              await prefs.setBool(key, true);
              if (context.mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ご注意'),
                    content: const Text(
                      'このアプリは医療機器ではありません。\n症状が続く場合や気になる点がある場合は、医師にご相談ください。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('確認しました'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _PresetChips(
                  selectedId: viewModel.selectedPresetId,
                  isPlaying: isPlaying,
                  onSelected: onPresetSelected,
                  onInfo: (preset) => _showPresetDetails(context, preset, colorScheme, textTheme),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FrequencyControl(
                          frequency: viewModel.frequency,
                          isPlaying: isPlaying,
                          onChanged: viewModel.updateFrequency,
                          onStep: isPlaying ? null : viewModel.stepFrequency,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 40),
                        if (!isLoop)
                          _DurationControl(
                            duration: viewModel.duration,
                            isPlaying: isPlaying,
                            onChanged: viewModel.updateDuration,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        if (isLoop)
                          _LoopBadge(colorScheme: colorScheme, textTheme: textTheme),
                        const SizedBox(height: 32),
                        _PlaybackProgress(
                          isPlaying: isPlaying,
                          isLoop: isLoop,
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
              ],
            ),
          ),
        );
      },
    );
  }
}

void _showPresetDetails(
  BuildContext context,
  SoundPreset preset,
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '${preset.emoji} ${preset.label}',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            preset.details,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          if (preset.warning != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, size: 18, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      preset.warning!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _PresetChips extends StatelessWidget {
  final String? selectedId;
  final bool isPlaying;
  final Future<void> Function(SoundPreset) onSelected;
  final void Function(SoundPreset) onInfo;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PresetChips({
    required this.selectedId,
    required this.isPlaying,
    required this.onSelected,
    required this.onInfo,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: kPresets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final preset = kPresets[i];
          final selected = preset.id == selectedId;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChoiceChip(
                label: Text('${preset.emoji} ${preset.label}'),
                selected: selected,
                onSelected: isPlaying ? null : (_) => onSelected(preset),
              ),
              if (selected)
                IconButton(
                  icon: Icon(Icons.info_outline,
                      size: 18, color: colorScheme.primary),
                  onPressed: () => onInfo(preset),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LoopBadge extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _LoopBadge({required this.colorScheme, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.loop, size: 16, color: colorScheme.secondary),
        const SizedBox(width: 6),
        Text(
          'ループ再生',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
        ),
      ],
    );
  }
}

class _FrequencyControl extends StatelessWidget {
  final double frequency;
  final bool isPlaying;
  final ValueChanged<double> onChanged;
  final void Function(int delta)? onStep;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _FrequencyControl({
    required this.frequency,
    required this.isPlaying,
    required this.onChanged,
    required this.onStep,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final delta in [-100, -10, 10, 100])
              _StepButton(
                label: '${delta > 0 ? '+' : ''}$delta',
                onPressed: onStep != null ? () => onStep!(delta) : null,
                colorScheme: colorScheme,
              ),
          ],
        ),
        _SliderWithDisabledFeedback(
          isPlaying: isPlaying,
          child: Slider(
            value: _freqToSlider(frequency),
            min: 0,
            max: 1,
            semanticFormatterCallback: (v) => _formatFrequency(_sliderToFreq(v)),
            onChanged: isPlaying ? null : (t) => onChanged(_sliderToFreq(t)),
          ),
        ),
        Text(
          '範囲: 40Hz - 20kHz',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  const _StepButton({
    required this.label,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colorScheme.outline),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 12, color: colorScheme.secondary)),
      ),
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
        _SliderWithDisabledFeedback(
          isPlaying: isPlaying,
          child: Slider(
            value: _durToSlider(duration),
            min: 0,
            max: 1,
            semanticFormatterCallback: (v) => _formatDuration(_sliderToDur(v)),
            onChanged: isPlaying ? null : (t) => onChanged(_sliderToDur(t)),
          ),
        ),
        Text(
          '範囲: 1秒 - 1時間',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
      ],
    );
  }
}

class _SliderWithDisabledFeedback extends StatelessWidget {
  final bool isPlaying;
  final Widget child;

  const _SliderWithDisabledFeedback({
    required this.isPlaying,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('再生中は変更できません'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaybackProgress extends StatelessWidget {
  final bool isPlaying;
  final bool isLoop;
  final int remainingTime;
  final int totalDuration;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PlaybackProgress({
    required this.isPlaying,
    required this.isLoop,
    required this.remainingTime,
    required this.totalDuration,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) return const SizedBox(height: 56);

    if (isLoop) {
      return SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
            Text(
              '再生中',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
            ),
          ],
        ),
      );
    }

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
