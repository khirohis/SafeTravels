class SoundStatus {
  final bool isPlaying;
  final int frequency;
  final int duration;
  final int remainingTime;

  const SoundStatus({
    this.isPlaying = false,
    this.frequency = 0,
    this.duration = 0,
    this.remainingTime = 0,
  });

  SoundStatus copyWith({
    bool? isPlaying,
    int? frequency,
    int? duration,
    int? remainingTime,
  }) {
    return SoundStatus(
      isPlaying: isPlaying ?? this.isPlaying,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}
