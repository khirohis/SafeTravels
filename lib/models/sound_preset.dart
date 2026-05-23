class SoundPreset {
  final String id;
  final String label;
  final String emoji;
  final double frequency;
  final int durationSeconds;
  final bool isLoop;
  final String? warning;
  final bool requiresDisclaimer;
  final String details;

  const SoundPreset({
    required this.id,
    required this.label,
    required this.emoji,
    required this.frequency,
    required this.durationSeconds,
    required this.isLoop,
    this.warning,
    this.requiresDisclaimer = false,
    required this.details,
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
    details: '100Hzの低周波音が内耳の耳石器を刺激し、乱れた前庭系・自律神経を正常化します。吐き気やふらつきの緩和に。\n\n'
        '【使い方】乗り物に乗る前または酔い始めに再生。音量は控えめに。\n\n'
        '【根拠】名大・加藤昌志教授「Sound Spice」特許（PCT/JP2019/021688）',
  ),
  SoundPreset(
    id: 'tinnitus',
    label: '耳鳴り緩和',
    emoji: '👂',
    frequency: 4000,
    durationSeconds: 1800,
    isLoop: true,
    warning: 'このアプリは医療機器ではありません。症状が続く場合は医師にご相談ください',
    requiresDisclaimer: true,
    details: '耳鳴りと同じ周波数の音でマスキング（遮蔽）し、気になりにくくします。神経の過剰発火を抑える補聴器クリニックでも使われるサウンドセラピーの手法です。\n\n'
        '【使い方】スライダーで耳鳴りに近い周波数に合わせてください（一般的に1,000〜8,000Hz）。\n\n'
        '【根拠】Jastreboff の Tinnitus Retraining Therapy（TRT）、音響マスキング療法',
  ),
  SoundPreset(
    id: 'sleep',
    label: '睡眠補助',
    emoji: '😴',
    frequency: 150,
    durationSeconds: 3600,
    isLoop: true,
    warning: '就寝中は特に音量を下げてください',
    requiresDisclaimer: true,
    details: '100〜200Hzの低周波連続音は外部騒音をマスキングし、雨音・波音に似た鎮静効果があります。入眠を妨げる刺激を遮断します。\n\n'
        '【使い方】就寝前に再生。音量は最小限に。\n\n'
        '【根拠】ブラウンノイズと睡眠の研究（Schmidt et al.）',
  ),
  SoundPreset(
    id: 'focus',
    label: '集中・作業',
    emoji: '🎯',
    frequency: 40,
    durationSeconds: 1500,
    isLoop: true,
    details: '40Hzのガンマ波帯域の音刺激が脳波を同期（エントレインメント）させ、認知機能・注意力を高めます。\n\n'
        '【使い方】作業中に BGM として短時間ずつ使用。\n\n'
        '【根拠】Iaccarino et al. "Gamma frequency entrainment" (Nature, 2016)',
  ),
  SoundPreset(
    id: 'baby',
    label: '夜泣きケア',
    emoji: '👶',
    frequency: 150,
    durationSeconds: 3600,
    isLoop: true,
    warning: 'スピーカーを乳幼児から2m以上離してください',
    details: '150Hzは子宮内の血流音・環境音（100〜200Hz帯）に近く、新生児の安心感を刺激します。泣き止みや入眠を促します。\n\n'
        '【使い方】スピーカーを赤ちゃんから2m以上離して使用。音量は最小限に。\n\n'
        '【根拠】ホワイトノイズ療法（Spencer et al. Pediatrics, 1990）',
  ),
  SoundPreset(
    id: 'dog',
    label: '犬の無駄吠え',
    emoji: '🐕',
    frequency: 16000,
    durationSeconds: 10,
    isLoop: false,
    details: '犬の可聴域（最大65,000Hz）内の高周波が不快刺激となり、吠えや興奮した行動を一時的に抑制します。人間にはほぼ聞こえません。\n\n'
        '【使い方】吠えが始まったら短時間（10秒）再生。連続使用は避けてください。\n\n'
        '【注意】連続使用は犬にストレスを与える可能性があります。',
  ),
  SoundPreset(
    id: 'insect',
    label: '虫除け',
    emoji: '🦟',
    frequency: 18000,
    durationSeconds: 3600,
    isLoop: true,
    details: '蚊・ゴキブリなど一部の昆虫が嫌がる高周波帯域を継続的に発生させます。人間にはほとんど聞こえません。\n\n'
        '【使い方】屋外や就寝時にループ再生。\n\n'
        '【注意】科学的エビデンスは限定的です。補助手段として位置づけてください。',
  ),
];
