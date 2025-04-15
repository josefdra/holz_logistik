import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListPage extends StatelessWidget {
  const LocationListPage({super.key});

  static Route<void> route({Location? initialLocation}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => LocationListBloc(
          locationRepository: context.read<LocationRepository>(),
          shipmentRepository: context.read<ShipmentRepository>(),
        ),
        child: const LocationListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationListBloc(
        locationRepository: context.read<LocationRepository>(),
        shipmentRepository: context.read<ShipmentRepository>(),
      )..add(const LocationListSubscriptionRequested()),
      child: const Scaffold(
        body: Row(
          children: [
            Expanded(child: LocationList()),
          ],
        ),
      ),
    );
  }
}

class LocationList extends StatelessWidget {
  const LocationList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<LocationListBloc, LocationListState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == LocationListStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.locationListErrorSnackbarText),
                  ),
                );
            }
          },
        ),
      ],
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Standort suchen',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              context.read<LocationListBloc>().add(
                    LocationListSearchQueryChanged(value),
                  );
            },
          ),
          Expanded(
            child: BlocBuilder<LocationListBloc, LocationListState>(
              builder: (context, state) {
                if (state.locations.isEmpty) {
                  if (state.status == LocationListStatus.loading) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (state.status != LocationListStatus.success) {
                    return const SizedBox();
                  } else {
                    return Center(
                      child: Text(
                        l10n.locationListEmptyText,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }
                }

                return CupertinoScrollbar(
                  child: ListView.builder(
                    primary: true,
                    itemCount: state.searchQueryedLocations.length,
                    itemBuilder: (_, index) {
                      final location =
                          state.searchQueryedLocations.elementAt(index);
                      return LocationListTile(
                        location: location,
                        onTap: () {
                          showDialog<LocationDetailsWidget>(
                            context: context,
                            builder: (context) => LocationDetailsWidget(
                              location: location,
                            ),
                          );
                        },
                        onDelete: () {
                          context
                              .read<LocationListBloc>()
                              .add(LocationListLocationDeleted(location));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
