import 'package:flutter_soloud/flutter_soloud.dart';

class SoundService {
  AudioSource? _source;
  SoundHandle? _handle;

  Future<void> init() async {
    await SoLoud.instance.init();
  }

  Future<void> play(int frequencyHz, {bool loop = false}) async {
    await stop();
    _source = await SoLoud.instance.loadWaveform(
      WaveForm.sin,
      false,
      1.0,
      1.0,
    );
    SoLoud.instance.setWaveformFreq(_source!, frequencyHz.toDouble());
    _handle = SoLoud.instance.play(_source!, looping: loop);
  }

  Future<void> stop() async {
    if (_handle != null) {
      try {
        await SoLoud.instance.stop(_handle!);
      } catch (_) {}
      _handle = null;
    }
    if (_source != null) {
      try {
        await SoLoud.instance.disposeSource(_source!);
      } catch (_) {}
      _source = null;
    }
  }

  void dispose() {
    stop();
    SoLoud.instance.deinit();
  }
}
