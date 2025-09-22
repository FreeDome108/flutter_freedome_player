import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/dome_config.dart';
import '../models/media_content.dart';

/// Сервис для работы с купольной проекцией FreeDome
class DomeProjectionService {
  static final DomeProjectionService _instance =
      DomeProjectionService._internal();
  factory DomeProjectionService() => _instance;
  DomeProjectionService._internal();

  DomeConfig? _config;
  bool _isConnected = false;
  String? _connectedDomeName;
  List<String> _availableDomes = [];

  /// Инициализировать подключение к FreeDome Engine
  Future<bool> initialize(DomeConfig config) async {
    try {
      _config = config;
      debugPrint(
          '🔵 [DOME_SERVICE] Initializing connection to ${config.freedomeEngineUrl}');

      if (config.freedomeEngineUrl == null) {
        debugPrint('🔴 [DOME_SERVICE] FreeDome Engine URL not specified');
        return false;
      }

      // Проверяем доступность FreeDome Engine
      final response = await http.get(
        Uri.parse('${config.freedomeEngineUrl}/api/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isConnected = true;
        _connectedDomeName = data['dome_name'] ?? 'FreeDome';

        debugPrint('🟢 [DOME_SERVICE] Connected to ${_connectedDomeName}');

        // Получаем список доступных куполов
        await _fetchAvailableDomes();

        return true;
      } else {
        debugPrint(
            '🔴 [DOME_SERVICE] Failed to connect: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Connection error: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Отправить медиа контент в купол
  Future<bool> sendModel(MediaContent content) async {
    if (!_isConnected || _config == null) {
      debugPrint('🔴 [DOME_SERVICE] Not connected to FreeDome Engine');
      return false;
    }

    try {
      debugPrint('🔵 [DOME_SERVICE] Sending model to dome: ${content.name}');

      final payload = {
        'content': {
          'id': content.id,
          'name': content.name,
          'filePath': content.filePath,
          'format': content.format.name,
          'playbackMode': content.playbackMode.name,
          'metadata': content.metadata,
        },
        'projection': {
          'type': _config!.projectionType.name,
          'dome_radius': _config!.domeRadius,
          'projector_count': _config!.projectorCount,
          'edge_blending': _config!.edgeBlending,
          'color_correction': _config!.colorCorrection,
        },
        'quantum_properties': _config!.quantumProperties.toJson(),
      };

      final response = await http
          .post(
            Uri.parse('${_config!.freedomeEngineUrl}/api/content/load'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('🟢 [DOME_SERVICE] Model sent successfully');

        // Настраиваем проекцию
        await _configureProjection();

        return true;
      } else {
        debugPrint(
            '🔴 [DOME_SERVICE] Failed to send model: ${response.statusCode}');
        debugPrint('🔴 [DOME_SERVICE] Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error sending model: $e');
      return false;
    }
  }

  /// Отправить ZELIM контент
  Future<bool> sendZelimContent(String zelimPath, String modelName) async {
    if (!_isConnected || _config == null) {
      debugPrint('🔴 [DOME_SERVICE] Not connected to FreeDome Engine');
      return false;
    }

    try {
      debugPrint('🔵 [DOME_SERVICE] Sending ZELIM content: $modelName');

      final payload = {
        'zelim_path': zelimPath,
        'model_name': modelName,
        'projection_type': _config!.projectionType.name,
        'quantum_properties': _config!.quantumProperties.toJson(),
      };

      final response = await http
          .post(
            Uri.parse('${_config!.freedomeEngineUrl}/api/zelim/load'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('🟢 [DOME_SERVICE] ZELIM content sent successfully');
        return true;
      } else {
        debugPrint(
            '🔴 [DOME_SERVICE] Failed to send ZELIM: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error sending ZELIM: $e');
      return false;
    }
  }

  /// Установить режим проекции
  Future<bool> setProjectionMode(String mode) async {
    if (!_isConnected || _config == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${_config!.freedomeEngineUrl}/api/projection/mode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mode': mode}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error setting projection mode: $e');
      return false;
    }
  }

  /// Включить квантовый режим
  Future<bool> setQuantumMode(bool enabled) async {
    if (!_isConnected || _config == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${_config!.freedomeEngineUrl}/api/quantum/mode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'enabled': enabled,
          'quantum_properties': _config!.quantumProperties.toJson(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error setting quantum mode: $e');
      return false;
    }
  }

  /// Воспроизвести пространственное аудио
  Future<bool> playAudio(String audioPath, {bool spatial = true}) async {
    if (!_isConnected || _config == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${_config!.freedomeEngineUrl}/api/audio/play'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'audio_path': audioPath,
          'spatial': spatial,
          'quantum_frequencies': _config!.quantumProperties.toJson(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error playing audio: $e');
      return false;
    }
  }

  /// Отправить OSC команду
  Future<bool> sendOSCCommand(String address, List<dynamic> args) async {
    if (!_isConnected || _config == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${_config!.freedomeEngineUrl}/api/osc/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'address': address,
          'args': args,
          'host': _config!.oscHost,
          'port': _config!.oscPort,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error sending OSC command: $e');
      return false;
    }
  }

  /// Получить статус купола
  Future<Map<String, dynamic>?> getDomeStatus() async {
    if (!_isConnected || _config == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${_config!.freedomeEngineUrl}/api/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error getting dome status: $e');
    }

    return null;
  }

  /// Отключиться от FreeDome Engine
  Future<void> disconnect() async {
    if (_isConnected && _config != null) {
      try {
        await http.post(
          Uri.parse('${_config!.freedomeEngineUrl}/api/disconnect'),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        debugPrint('🔴 [DOME_SERVICE] Error disconnecting: $e');
      }
    }

    _isConnected = false;
    _connectedDomeName = null;
    _config = null;
  }

  /// Получить список доступных куполов
  Future<void> _fetchAvailableDomes() async {
    if (!_isConnected || _config == null) return;

    try {
      final response = await http.get(
        Uri.parse('${_config!.freedomeEngineUrl}/api/domes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _availableDomes = List<String>.from(data['domes'] ?? []);
        debugPrint('🟢 [DOME_SERVICE] Available domes: $_availableDomes');
      }
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error fetching available domes: $e');
    }
  }

  /// Настроить проекцию
  Future<void> _configureProjection() async {
    if (!_isConnected || _config == null) return;

    try {
      // Устанавливаем режим проекции
      await setProjectionMode(_config!.projectionType.name);

      // Включаем квантовый режим
      await setQuantumMode(true);

      // Отправляем дополнительные OSC команды
      await sendOSCCommand('/dome/radius', [_config!.domeRadius]);
      await sendOSCCommand(
          '/projection/edge_blending', [_config!.edgeBlending]);
      await sendOSCCommand(
          '/projection/color_correction', [_config!.colorCorrection]);

      debugPrint('🟢 [DOME_SERVICE] Projection configured successfully');
    } catch (e) {
      debugPrint('🔴 [DOME_SERVICE] Error configuring projection: $e');
    }
  }

  // Геттеры
  bool get isConnected => _isConnected;
  String? get connectedDomeName => _connectedDomeName;
  List<String> get availableDomes => _availableDomes;
  DomeConfig? get config => _config;
}
