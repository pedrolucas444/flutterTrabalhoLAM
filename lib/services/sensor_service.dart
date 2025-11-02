import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

class SensorService {
  static final SensorService instance = SensorService._init();
  SensorService._init();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Function()? _onShake;
  
  static const double _shakeThreshold = 15.0;
  static const Duration _shakeCooldown = Duration(milliseconds: 500);
  
  DateTime? _lastShakeTime;
  bool _isActive = false;
  
  bool get isActive => _isActive;

  void startShakeDetection(Function() onShake) {
    if (_isActive) {
      print('⚠️ Detecção já ativa');
      return;
    }
    // Guard against platforms where sensors_plus might not be available
    // (desktop/macOS in some plugin configurations). Only subscribe on
    // mobile platforms (Android/iOS) or web where the plugin provides
    // implementations. Otherwise, skip subscription and keep service
    // inactive to avoid MissingPluginException at runtime.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      print('⚠️ SensorService: shake detection not supported on this platform (${kIsWeb ? 'web' : Platform.operatingSystem})');
      return;
    }

    _onShake = onShake;
    _isActive = true;

    try {
      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _detectShake(event);
        },
        onError: (error) {
          print('❌ Erro no acelerômetro: $error');
        },
      );

      print('📱 Detecção de shake iniciada');
    } catch (e) {
      // Catch MissingPluginException and similar runtime errors so the
      // app doesn't crash on platforms without the native implementation.
      print('⚠️ Não foi possível ativar sensores: $e');
      _isActive = false;
      _accelerometerSubscription = null;
      _onShake = null;
    }
  }

  void _detectShake(AccelerometerEvent event) {
    final now = DateTime.now();
    
    if (_lastShakeTime != null && 
        now.difference(_lastShakeTime!) < _shakeCooldown) {
      return;
    }

    final double magnitude = math.sqrt(
      event.x * event.x + 
      event.y * event.y + 
      event.z * event.z
    );

    if (magnitude > _shakeThreshold) {
      print('🔳 Shake! Magnitude: ${magnitude.toStringAsFixed(2)}');
      _lastShakeTime = now;
      _vibrateDevice();
      _onShake?.call();
    }
  }

  Future<void> _vibrateDevice() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      print('⚠️ Vibração não suportada: $e');
    }
  }

  void stop() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _onShake = null;
    _isActive = false;
    print('⏹️ Detecção de shake parada');
  }
}