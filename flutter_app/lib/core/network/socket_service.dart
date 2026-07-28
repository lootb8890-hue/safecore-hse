import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';

/**
 * Zero-Latency Emergency Siren & Real-time Chat Socket Provider.
 * Maintains persistent high-priority WebSocket connection to NestJS namespace [/hse].
 * Instantly triggers acoustic siren alarms and fullscreen red visual alerts when fired by any colleague.
 */
class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isConnected = false;
  bool _activeSirenAlert = false;
  Map<String, dynamic>? _lastEmergencyPayload;
  final List<Map<String, dynamic>> _liveChatFeed = [];

  bool get isConnected => _isConnected;
  bool get activeSirenAlert => _activeSirenAlert;
  Map<String, dynamic>? get lastEmergencyPayload => _lastEmergencyPayload;
  List<Map<String, dynamic>> get liveChatFeed => _liveChatFeed;

  void connect(String serverUrl, String jwtToken) {
    if (_socket != null && _socket!.connected) return;

    final url = serverUrl.endsWith('/hse') ? serverUrl : '$serverUrl/hse';
    debugPrint('🔌 [SocketService] Connecting to Realtime HSE Gateway at: $url');

    _socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({'token': jwtToken})
        .enableAutoConnect()
        .build());

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('🟢 [SocketService] Connected to Realtime Emergency Hub!');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔴 [SocketService] Disconnected from hub.');
      notifyListeners();
    });

    // Zero-Latency Emergency Siren Listener
    _socket!.on('EMERGENCY_SIREN_TRIGGERED', (data) {
      debugPrint('🚨🚨🚨 [SocketService] EMERGENCY SIREN BROADCAST RECEIVED: $data');
      _activeSirenAlert = true;
      _lastEmergencyPayload = Map<String, dynamic>.from(data ?? {});
      _playAlarmSound();
      notifyListeners();
    });

    // Live Internal Chat Listener
    _socket!.on('CHAT_MESSAGE_RECEIVED', (data) {
      if (data != null) {
        _liveChatFeed.insert(0, Map<String, dynamic>.from(data));
        notifyListeners();
      }
    });

    _socket!.connect();
  }

  void triggerLocalSimulatedEmergency(Map<String, dynamic> sampleAlert) {
    _activeSirenAlert = true;
    _lastEmergencyPayload = sampleAlert;
    _playAlarmSound();
    notifyListeners();
  }

  void dismissActiveAlarm() {
    _activeSirenAlert = false;
    _lastEmergencyPayload = null;
    _audioPlayer.stop();
    notifyListeners();
  }

  Future<void> _playAlarmSound() async {
    try {
      // Plays standard industrial siren tone or synthesized audio
      await _audioPlayer.play(AssetSource('sounds/emergency_siren.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('⚠️ Audio alert playback notice (Asset acoustic file simulation active): $e');
    }
  }

  void sendChatMessage(Map<String, dynamic> messagePayload) {
    if (_socket != null && _isConnected) {
      _socket!.emit('send_chat_message', messagePayload);
    } else {
      _liveChatFeed.insert(0, messagePayload);
      notifyListeners();
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
  }
}
