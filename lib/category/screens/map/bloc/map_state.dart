part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

final class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.addMarkerMode = false,
    this.showInfoMode = false,
    this.markers = const [],
    this.userLocation,
    this.trackingMode = true,
    this.newMarkerPosition,
  });

  final MapStatus status;
  final bool addMarkerMode;
  final bool showInfoMode;
  final List<Marker> markers;
  final LatLng? userLocation;
  final bool trackingMode;
  final LatLng? newMarkerPosition;

  MapState copyWith({
    MapStatus? status,
    bool? addMarkerMode,
    bool? showInfoMode,
    List<Marker>? markers,
    LatLng? userLocation,
    Marker? userLocationMarker,
    bool? trackingMode,
    LatLng? newMarkerPosition,
  }) {
    return MapState(
      status: status ?? this.status,
      addMarkerMode: addMarkerMode ?? this.addMarkerMode,
      showInfoMode: showInfoMode ?? this.showInfoMode,
      markers: markers ?? this.markers,
      userLocation: userLocation ?? this.userLocation,
      trackingMode: trackingMode ?? this.trackingMode,
      newMarkerPosition: newMarkerPosition ?? this.newMarkerPosition,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addMarkerMode,
        showInfoMode,
        markers,
        userLocation,
        trackingMode,
        newMarkerPosition,
      ];
}
