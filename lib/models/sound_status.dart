class SoundStatus {
  final bool isPlaying;
  final int remainingTime;

  const SoundStatus({
    this.isPlaying = false,
    this.remainingTime = 0,
  });

  SoundStatus copyWith({
    bool? isPlaying,
    int? remainingTime,
  }) {
    return SoundStatus(
      isPlaying: isPlaying ?? this.isPlaying,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}
