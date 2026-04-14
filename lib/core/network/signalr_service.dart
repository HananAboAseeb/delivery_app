import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';

/// Single Responsibility: Manages the SignalR WebSocket connection
/// and provides streams for real-time app events.
class SignalRService {
  HubConnection? _hubConnection;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _hubUrl =
      'https://erp.neosending.com/hubs/commerce-financial';

  // Streams for broadcasting real-time events to the BLoCs
  final _orderStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _driverLocationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onOrderStatusChanged =>
      _orderStatusController.stream;
  Stream<Map<String, dynamic>> get onDriverLocationUpdated =>
      _driverLocationController.stream;

  /// Initializes the connection. Call this after successful login.
  Future<void> connect() async {
    if (_hubConnection?.state == HubConnectionState.connected) return;

    final token = await _storage.read(key: 'access_token');

    _hubConnection = HubConnectionBuilder()
        .withUrl(
            _hubUrl,
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.webSockets,
              skipNegotiation: false,
            ))
        .withAutomaticReconnect(
            <int>[0, 2000, 10000, 30000]) // Exponential backoff retries
        .build();

    // Register generic connection listeners
    _hubConnection
        ?.onclose((error) => print('SignalR Connection Closed: $error'));
    _hubConnection
        ?.onreconnecting((error) => print('SignalR Reconnecting: $error'));
    _hubConnection?.onreconnected(
        (connectionId) => print('SignalR Reconnected! ID: $connectionId'));

    // Register event hooks from Swagger/abp analysis
    _setupEventHooks();

    try {
      await _hubConnection?.start();
      print('SignalR Service Connected successfully.');
    } catch (e) {
      print('Failed to start SignalR connection: $e');
    }
  }

  void _setupEventHooks() {
    // Expected hook: OrderStatusChanged
    _hubConnection?.on('OrderStatusChanged', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final payload = arguments[0] as Map<String, dynamic>;
        _orderStatusController.add(payload);
      }
    });

    // Expected hook: DriverLocationUpdated
    _hubConnection?.on('DriverLocationUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final payload = arguments[0] as Map<String, dynamic>;
        _driverLocationController.add(payload);
      }
    });
  }

  /// Use this to subscribe to a specific order's live tracking stream
  Future<void> joinOrderGroup(String orderId) async {
    if (_hubConnection?.state == HubConnectionState.connected) {
      await _hubConnection?.invoke('JoinOrderGroup', args: [orderId]);
    }
  }

  /// Use this to unsubscribe
  Future<void> leaveOrderGroup(String orderId) async {
    if (_hubConnection?.state == HubConnectionState.connected) {
      await _hubConnection?.invoke('LeaveOrderGroup', args: [orderId]);
    }
  }

  void dispose() {
    _hubConnection?.stop();
    _orderStatusController.close();
    _driverLocationController.close();
  }
}
