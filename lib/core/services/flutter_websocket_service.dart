import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:clinic_app/core/config/api_config.dart';
import 'package:clinic_app/core/services/api_service.dart';
import 'package:clinic_app/core/services/logger_service.dart';

/// WebSocket service for realtime updates from PostgreSQL backend
class FlutterWebSocketService {
  static final FlutterWebSocketService _instance =
      FlutterWebSocketService._internal();
  factory FlutterWebSocketService() => _instance;

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final ApiService _apiService = ApiService();
  final _logger = LoggerService();

  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;

  final Set<String> _subscribedCollections = {};

  FlutterWebSocketService._internal();

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected) {
      _logger.info('WebSocket already connected');
      return;
    }

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      _logger.info('Connecting to WebSocket...');

      // Build WebSocket URL with token
      final wsUrl = '${ApiConfig.wsUrl}?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _isConnected = true;
      _reconnectAttempts = 0;

      _logger.info('✅ WebSocket connected');

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      // Start ping/pong heartbeat
      _startHeartbeat();

      // Resubscribe to collections after reconnection
      if (_subscribedCollections.isNotEmpty) {
        for (final collection in _subscribedCollections) {
          _sendSubscribe(collection);
        }
      }
    } catch (e) {
      _logger.error('WebSocket connection error', e, StackTrace.current);
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      _logger.info('📥 WebSocket message: ${data['type']}');

      switch (data['type']) {
        case 'connected':
          _logger.info('WebSocket connection confirmed');
          break;

        case 'subscribed':
          _logger.info('Subscribed to ${data['collection']}');
          break;

        case 'unsubscribed':
          _logger.info('Unsubscribed from ${data['collection']}');
          break;

        case 'update':
          _logger.info('Update: ${data['action']} on ${data['collection']}');
          _messageController.add(data);
          break;

        case 'pong':
          // Heartbeat response
          break;

        case 'error':
          _logger.warning('WebSocket error: ${data['message']}');
          break;

        default:
          _logger.warning('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      _logger.error('Error handling WebSocket message', e, StackTrace.current);
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    _logger.error('WebSocket error', error, StackTrace.current);
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Handle disconnection
  void _handleDisconnect() {
    _logger.info('WebSocket disconnected');
    _isConnected = false;
    _stopHeartbeat();
    _scheduleReconnect();
  }

  /// Subscribe to a collection for updates
  void subscribe(String collection) {
    if (!_isConnected) {
      _logger.warning('Cannot subscribe: WebSocket not connected');
      return;
    }

    _subscribedCollections.add(collection);
    _sendSubscribe(collection);
  }

  /// Send subscribe message
  void _sendSubscribe(String collection) {
    _send({
      'type': 'subscribe',
      'collection': collection,
    });
  }

  /// Unsubscribe from a collection
  void unsubscribe(String collection) {
    _subscribedCollections.remove(collection);

    if (_isConnected) {
      _send({
        'type': 'unsubscribe',
        'collection': collection,
      });
    }
  }

  /// Send a message through WebSocket
  void _send(Map<String, dynamic> message) {
    if (_channel == null) return;

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      _logger.error('Error sending WebSocket message', e, StackTrace.current);
    }
  }

  /// Start heartbeat (ping/pong)
  void _startHeartbeat() {
    _stopHeartbeat();

    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _send({'type': 'ping'});
      }
    });
  }

  /// Stop heartbeat
  void _stopHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }

    if (_reconnectAttempts >= ApiConfig.maxReconnectAttempts) {
      _logger.warning('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = ApiConfig.reconnectDelay * _reconnectAttempts;

    _logger.info(
        'Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      _logger.info('Attempting to reconnect...');
      connect();
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _logger.info('Disconnecting WebSocket...');

    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _channel?.sink.close();
    _channel = null;

    _isConnected = false;
    _reconnectAttempts = 0;
    _subscribedCollections.clear();

    _logger.info('WebSocket disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}

