class SoundPreset {
  final String id;
  final String label;
  final String emoji;
  final double frequency;
  final int durationSeconds;
  final bool isLoop;
  final String? warning;

  const SoundPreset({
    required this.id,
    required this.label,
    required this.emoji,
    required this.frequency,
    required this.durationSeconds,
    required this.isLoop,
    this.warning,
  });
}

const kPresets = <SoundPreset>[
  SoundPreset(
    id: 'motion_sickness',
    label: '乗り物酔い',
    emoji: '🚗',
    frequency: 100,
    durationSeconds: 60,
    isLoop: false,
    warning: '音量を50%以下（60dB以下）に設定してください',
  ),
  SoundPreset(
    id: 'tinnitus',
    label: '耳鳴り緩和',
    emoji: '👂',
    frequency: 4000,
    durationSeconds: 1800,
    isLoop: true,
    warning: 'このアプリは医療機器ではありません。症状が続く場合は医師にご相談ください',
  ),
  SoundPreset(
    id: 'sleep',
    label: '睡眠補助',
    emoji: '😴',
    frequency: 150,
    durationSeconds: 3600,
    isLoop: true,
    warning: '就寝中は特に音量を下げてください',
  ),
  SoundPreset(
    id: 'focus',
    label: '集中・作業',
    emoji: '🎯',
    frequency: 40,
    durationSeconds: 1500,
    isLoop: true,
  ),
  SoundPreset(
    id: 'baby',
    label: '夜泣きケア',
    emoji: '👶',
    frequency: 150,
    durationSeconds: 3600,
    isLoop: true,
    warning: 'スピーカーを乳幼児から2m以上離してください',
  ),
  SoundPreset(
    id: 'dog',
    label: '犬の無駄吠え',
    emoji: '🐕',
    frequency: 16000,
    durationSeconds: 10,
    isLoop: false,
  ),
  SoundPreset(
    id: 'insect',
    label: '虫除け',
    emoji: '🦟',
    frequency: 18000,
    durationSeconds: 3600,
    isLoop: true,
  ),
];
