import 'dart:async';

import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template photo_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class PhotoSyncService {
  /// {@macro photo_sync_service}
  PhotoSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerHandler('photo_update', _handlePhotoUpdate);
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _photoUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of photo updates from external sources
  Stream<Map<String, dynamic>> get photoUpdates =>
      _photoUpdateController.stream;

  void _handlePhotoUpdate(dynamic data) {
    try {
      _photoUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send photo updates to server
  Future<void> sendPhotoUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('photo_update', data);
  }

  /// Dispose
  void dispose() {
    _photoUpdateController.close();
  }
}
