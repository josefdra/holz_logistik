import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/models.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'location_details_event.dart';
part 'location_details_state.dart';

class LocationDetailsBloc
    extends Bloc<LocationDetailsEvent, LocationDetailsState> {
  LocationDetailsBloc({
    required LocationRepository locationsRepository,
    required ContractRepository contractRepository,
    required SawmillRepository sawmillRepository,
    required ShipmentRepository shipmentRepository,
    required PhotoRepository photoRepository,
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
    required Location initialLocation,
  })  : _locationsRepository = locationsRepository,
        _contractRepository = contractRepository,
        _sawmillRepository = sawmillRepository,
        _photoRepository = photoRepository,
        _shipmentRepository = shipmentRepository,
        _userRepository = userRepository,
        _authenticationRepository = authenticationRepository,
        super(
          LocationDetailsState(
            location: initialLocation,
          ),
        ) {
    on<LocationDetailsSubscriptionRequested>(_onSubscriptionRequested);
    on<LocationDetailsInitNames>(_onInitNames);
    on<LocationDetailsLocationUpdate>(_onLocationUpdate);
    on<LocationDetailsContractUpdate>(_onContractUpdate);
    on<LocationDetailsSawmillUpdate>(_onSawmillUpdate);
    on<LocationDetailsOversizeSawmillUpdate>(_onOversizeSawmillUpdate);
    on<LocationDetailsShipmentUpdate>(_onShipmentUpdate);
    on<LocationDetailsPhotosChanged>(_onPhotosChanged);
    on<LocationDetailsUserUpdate>(_onUserUpdate);
    on<LocationDetailsUsersUpdate>(_onUsersUpdate);
    on<LocationDetailsSawmillsUpdate>(_onSawmillsUpdate);
    on<LocationDetailsLocationReactivated>(_onLocationReactivated);
  }

  final LocationRepository _locationsRepository;
  final ContractRepository _contractRepository;
  final SawmillRepository _sawmillRepository;
  final ShipmentRepository _shipmentRepository;
  final PhotoRepository _photoRepository;
  final UserRepository _userRepository;
  final AuthenticationRepository _authenticationRepository;

  late final StreamSubscription<Location>? _locationUpdatesSubscription;
  late final StreamSubscription<Contract>? _contractUpdatesSubscription;
  late final StreamSubscription<List<Sawmill>>? _sawmillSubscription;
  late final StreamSubscription<List<Sawmill>>? _oversizeSawmillSubscription;
  late final StreamSubscription<Shipment>? _shipmentUpdateSubscription;
  late final StreamSubscription<String>? _photoUpdateSubscription;
  late final StreamSubscription<Map<String, User>>? _usersSubscription;
  late final StreamSubscription<Map<String, Sawmill>>? _sawmillsSubscription;
  late final StreamSubscription<User>? _authenticationSubscription;

  void _onSubscriptionRequested(
    LocationDetailsSubscriptionRequested event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(status: LocationDetailsStatus.loading));
    add(const LocationDetailsInitNames());

    try {
      _locationUpdatesSubscription =
          _locationsRepository.locationUpdates.listen((location) {
        if (location.id == state.location.id) {
          add(LocationDetailsLocationUpdate(location));
        }
      });

      _contractUpdatesSubscription =
          _contractRepository.contractUpdates.listen((contract) {
        if (contract.id == state.location.contractId) {
          add(LocationDetailsContractUpdate(contract));
        }
      });

      _sawmillSubscription = _sawmillRepository.sawmills.map(
        (sawmills) {
          final sawmillIds = state.location.sawmillIds;
          if (sawmillIds.isEmpty) {
            return <Sawmill>[];
          }
          return sawmills.values
              .where(
                (sawmill) => state.location.sawmillIds.contains(sawmill.id),
              )
              .toList();
        },
      ).listen(
        (filteredSawmills) =>
            add(LocationDetailsSawmillUpdate(filteredSawmills)),
      );

      _oversizeSawmillSubscription = _sawmillRepository.sawmills.map(
        (sawmills) {
          final sawmillIds = state.location.sawmillIds;
          if (sawmillIds.isEmpty) {
            return <Sawmill>[];
          }
          return sawmills.values
              .where(
                (sawmill) =>
                    state.location.oversizeSawmillIds.contains(sawmill.id),
              )
              .toList();
        },
      ).listen(
        (filteredOversizeSawmills) => add(
          LocationDetailsOversizeSawmillUpdate(filteredOversizeSawmills),
        ),
      );

      _shipmentUpdateSubscription = _shipmentRepository.shipmentUpdates.listen(
        (shipment) {
          if (shipment.locationId == state.location.id) {
            add(LocationDetailsShipmentUpdate(shipment.locationId));
          }
        },
      );

      _photoUpdateSubscription = _photoRepository.photoUpdates.listen(
        (locationId) {
          add(LocationDetailsPhotosChanged(locationId));
        },
      );

      _usersSubscription = _userRepository.users
          .listen((users) => add(LocationDetailsUsersUpdate(users)));

      _sawmillsSubscription = _sawmillRepository.sawmills
          .listen((sawmills) => add(LocationDetailsSawmillsUpdate(sawmills)));

      add(LocationDetailsShipmentUpdate(state.location.id));
      add(LocationDetailsPhotosChanged(state.location.id));
      _refreshContract();

      _authenticationSubscription =
          _authenticationRepository.authenticatedUser.listen(
        (user) => add(LocationDetailsUserUpdate(user)),
      );

      emit(
        state.copyWith(
          status: LocationDetailsStatus.success,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LocationDetailsStatus.failure));
    }
  }

  Future<void> _onInitNames(
    LocationDetailsInitNames event,
    Emitter<LocationDetailsState> emit,
  ) async {
    final users = await _userRepository.users.first;
    final userNames = <String, String>{};
    for (final key in users.keys) {
      userNames[key] = users[key]!.name;
    }
    final sawmills = await _sawmillRepository.sawmills.first;
    final sawmillNames = <String, String>{};
    for (final key in sawmills.keys) {
      sawmillNames[key] = sawmills[key]!.name;
    }
    emit(state.copyWith(userNames: userNames, sawmillNames: sawmillNames));
  }

  Future<void> _refreshContract() async {
    if (state.location.contractId != '') {
      final contract =
          await _contractRepository.getContractById(state.location.contractId);
      add(LocationDetailsContractUpdate(contract));
    }
  }

  void _refreshSawmills() {
    final sawmillIds = state.location.sawmillIds;
    if (sawmillIds.isEmpty) {
      add(const LocationDetailsSawmillUpdate(<Sawmill>[]));
      return;
    }

    _sawmillRepository.sawmills.first.then((sawmills) {
      final filteredSawmills = <Sawmill>[];
      for (final id in sawmillIds) {
        final sawmill = sawmills[id];
        if (sawmill != null) {
          filteredSawmills.add(sawmill);
        }
      }
      add(LocationDetailsSawmillUpdate(filteredSawmills));
    });
  }

  void _refreshOversizeSawmills() {
    final oversizeSawmillIds = state.location.oversizeSawmillIds;
    if (oversizeSawmillIds.isEmpty) {
      add(const LocationDetailsOversizeSawmillUpdate(<Sawmill>[]));
      return;
    }

    _sawmillRepository.sawmills.first.then((sawmills) {
      final filteredOversizeSawmills = <Sawmill>[];
      for (final id in oversizeSawmillIds) {
        final sawmill = sawmills[id];
        if (sawmill != null) {
          filteredOversizeSawmills.add(sawmill);
        }
      }
      add(LocationDetailsOversizeSawmillUpdate(filteredOversizeSawmills));
    });
  }

  void _onLocationUpdate(
    LocationDetailsLocationUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(location: event.location));

    _refreshContract();
    _refreshSawmills();
    _refreshOversizeSawmills();
  }

  void _onContractUpdate(
    LocationDetailsContractUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(contract: event.contract));
  }

  void _onSawmillUpdate(
    LocationDetailsSawmillUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(sawmills: event.sawmills));
  }

  void _onOversizeSawmillUpdate(
    LocationDetailsOversizeSawmillUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(oversizeSawmills: event.oversizeSawmills));
  }

  Future<void> _onShipmentUpdate(
    LocationDetailsShipmentUpdate event,
    Emitter<LocationDetailsState> emit,
  ) async {
    final shipments =
        await _shipmentRepository.getShipmentsByLocation(event.locationId);

    emit(state.copyWith(shipments: shipments));
  }

  Future<void> _onPhotosChanged(
    LocationDetailsPhotosChanged event,
    Emitter<LocationDetailsState> emit,
  ) async {
    final photos = await _photoRepository.getPhotosByLocation(event.locationId);

    emit(state.copyWith(photos: photos));
  }

  Future<void> _onUserUpdate(
    LocationDetailsUserUpdate event,
    Emitter<LocationDetailsState> emit,
  ) async {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onUsersUpdate(
    LocationDetailsUsersUpdate event,
    Emitter<LocationDetailsState> emit,
  ) async {
    final userNames = <String, String>{};
    for (final key in event.users.keys) {
      userNames[key] = event.users[key]!.name;
    }

    emit(state.copyWith(userNames: userNames));
  }

  Future<void> _onSawmillsUpdate(
    LocationDetailsSawmillsUpdate event,
    Emitter<LocationDetailsState> emit,
  ) async {
    final sawmillNames = <String, String>{};
    for (final key in event.sawmills.keys) {
      sawmillNames[key] = event.sawmills[key]!.name;
    }

    emit(state.copyWith(sawmillNames: sawmillNames));
  }

  Future<void> _onLocationReactivated(
    LocationDetailsLocationReactivated event,
    Emitter<LocationDetailsState> emit,
  ) async {
    await _locationsRepository
        .saveLocation(state.location.copyWith(done: false));
    emit(state.copyWith(status: LocationDetailsStatus.close));
  }

  @override
  Future<void> close() async {
    await _locationUpdatesSubscription?.cancel();
    await _contractUpdatesSubscription?.cancel();
    await _sawmillSubscription?.cancel();
    await _oversizeSawmillSubscription?.cancel();
    await _shipmentUpdateSubscription?.cancel();
    await _photoUpdateSubscription?.cancel();
    await _usersSubscription?.cancel();
    await _sawmillsSubscription?.cancel();
    await _authenticationSubscription?.cancel();
    return super.close();
  }
}
