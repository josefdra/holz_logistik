import 'dart:async';

import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template shipment_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class ShipmentSyncService {
  /// {@macro shipment_sync_service}
  ShipmentSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerHandler('shipment_update', _handleShipmentUpdate);
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _shipmentUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of shipment updates from external sources
  Stream<Map<String, dynamic>> get shipmentUpdates =>
      _shipmentUpdateController.stream;

  void _handleShipmentUpdate(dynamic data) {
    try {
      _shipmentUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send shipment updates to server
  Future<void> sendShipmentUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('shipment_update', data);
  }

  /// Dispose
  void dispose() {
    _shipmentUpdateController.close();
  }
}
