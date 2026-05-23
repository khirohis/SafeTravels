class SoundStatus {
  final bool isPlaying;
  final bool isLoop;
  final int remainingTime;

  const SoundStatus({
    this.isPlaying = false,
    this.isLoop = false,
    this.remainingTime = 0,
  });

  SoundStatus copyWith({
    bool? isPlaying,
    bool? isLoop,
    int? remainingTime,
  }) {
    return SoundStatus(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoop: isLoop ?? this.isLoop,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}
