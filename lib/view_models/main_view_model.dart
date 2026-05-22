import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sound_status.dart';
import '../services/sound_service.dart';

class MainViewModel extends ChangeNotifier {
  final SoundService _service;

  double _frequency = 440.0;
  double _duration = 60.0;
  SoundStatus _status = const SoundStatus();
  Timer? _timer;

  MainViewModel(this._service);

  double get frequency => _frequency;
  double get duration => _duration;
  SoundStatus get status => _status;

  void updateFrequency(double value) {
    _frequency = value;
    notifyListeners();
  }

  void updateDuration(double value) {
    _duration = value;
    notifyListeners();
  }

  Future<void> togglePlayback() async {
    if (_status.isPlaying) {
      await _stopPlayback();
    } else {
      await _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    final durationSecs = _duration.toInt();
    _status = SoundStatus(
      isPlaying: true,
      frequency: _frequency.toInt(),
      duration: durationSecs,
      remainingTime: durationSecs,
    );
    notifyListeners();

    await _service.play(_frequency.toInt());

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newRemaining = _status.remainingTime - 1;
      if (newRemaining <= 0) {
        _stopPlayback();
      } else {
        _status = _status.copyWith(remainingTime: newRemaining);
        notifyListeners();
      }
    });
  }

  Future<void> _stopPlayback() async {
    _timer?.cancel();
    _timer = null;
    await _service.stop();
    _status = _status.copyWith(isPlaying: false, remainingTime: 0);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.stop();
    super.dispose();
  }
}
