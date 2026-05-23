import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/sound_preset.dart';
import '../models/sound_status.dart';
import '../services/sound_service.dart';

class MainViewModel extends ChangeNotifier {
  final SoundService _service;

  double _frequency = 440.0;
  double _duration = 60.0;
  bool _isLoop = false;
  String? _selectedPresetId;
  SoundStatus _status = const SoundStatus();
  Timer? _timer;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  double get frequency => _frequency;
  double get duration => _duration;
  bool get isLoop => _isLoop;
  String? get selectedPresetId => _selectedPresetId;
  SoundStatus get status => _status;

  MainViewModel(this._service) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await _service.init();
    _isInitialized = true;
    notifyListeners();
  }

  void selectPreset(SoundPreset preset) {
    _selectedPresetId = preset.id;
    _frequency = preset.frequency;
    _duration = preset.durationSeconds.toDouble();
    _isLoop = preset.isLoop;
    notifyListeners();
  }

  void updateFrequency(double value) {
    _frequency = value;
    notifyListeners();
  }

  void stepFrequency(int delta) {
    _frequency = (_frequency + delta).clamp(40.0, 20000.0);
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
    _status = SoundStatus(
      isPlaying: true,
      isLoop: _isLoop,
      remainingTime: _isLoop ? 0 : _duration.toInt(),
    );
    notifyListeners();

    await _service.play(_frequency.toInt(), loop: true);

    if (!_isLoop) {
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
