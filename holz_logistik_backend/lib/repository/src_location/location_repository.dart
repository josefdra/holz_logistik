import 'dart:async';

import 'package:holz_logistik_backend/api/location_api.dart';
import 'package:holz_logistik_backend/sync/location_sync_service.dart';

/// {@template location_repository}
/// A repository that handles `location` related requests.
/// {@endtemplate}
class LocationRepository {
  /// {@macro location_repository}
  LocationRepository({
    required LocationApi locationApi,
    required LocationSyncService locationSyncService,
  })  : _locationApi = locationApi,
        _locationSyncService = locationSyncService {
    _locationSyncService.locationUpdates.listen(_handleServerUpdate);
  }

  final LocationApi _locationApi;
  final LocationSyncService _locationSyncService;

  /// Provides a [Stream] of done locations.
  Stream<List<Location>> get doneLocations => _locationApi.doneLocations;

  /// Provides a [Stream] of active locations.
  Stream<List<Location>> get activeLocations => _locationApi.activeLocations;

  /// Provides all current active locations
  List<Location> get currentActiveLocations =>
      _locationApi.currentActiveLocations;

  /// Provides all current done locations
  List<Location> get currentDoneLocations => _locationApi.currentDoneLocations;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _locationApi.deleteLocation(
        id: data['id'] as String,
        done: data['done'] as bool,
      );
    } else {
      _locationApi.saveLocation(Location.fromJson(data));
    }
  }

  /// Saves a [location].
  ///
  /// If a [location] with the same id already exists, it will be replaced.
  Future<void> saveLocation(Location location) {
    _locationApi.saveLocation(location);
    return _locationSyncService.sendLocationUpdate(location.toJson());
  }

  /// Deletes the `location` with the given id.
  Future<void> deleteLocation({required String id, required bool done}) {
    _locationApi.deleteLocation(id: id, done: done);
    final data = {
      'id': id,
      'deleted': true,
      'done': done,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _locationSyncService.sendLocationUpdate(data);
  }

  /// Updates the `started` status of a location
  Future<void> unsetStarted(String locationId) async {
    final location = await _locationApi.getLocationById(locationId);
    final updatedLocation = location.copyWith(started: false);
    await _locationApi.saveLocation(updatedLocation);

    return _locationSyncService.sendLocationUpdate(updatedLocation.toJson());
  }

  /// Updates the `started` status of a location
  Future<void> setStarted(String locationId) async {
    final location = await _locationApi.getLocationById(locationId);
    final updatedLocation = location.copyWith(started: true);
    await _locationApi.saveLocation(updatedLocation);

    return _locationSyncService.sendLocationUpdate(updatedLocation.toJson());
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _locationApi.close();
}
