import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/utils/data_provider.dart';
import 'package:holz_logistik/widgets/location_details.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final Map<int, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
  }

  void _toggleExpanded(int locationId) {
    setState(() {
      _expandedState[locationId] = !(_expandedState[locationId] ?? false);
    });
  }

  Future<void> _handleUndoShipment(
      BuildContext context, Shipment shipment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abfuhr rückgängig machen'),
        content: const Text(
          'Möchten Sie diese Abfuhr wirklich rückgängig machen? '
          'Die Mengen werden zum Standort zurückgebucht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<DataProvider>().undoShipment(shipment.id);
        if (context.mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abfuhr wurde rückgängig gemacht')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Location>>(
        stream: DataProvider.archivedLocationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Keine Standorte mit Abfuhren gefunden'));
          }

          final locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return LocationShipmentsCard(
                key: ValueKey(location.id),
                location: location,
                isExpanded: _expandedState[location.id] ?? false,
                onToggleExpanded: () => _toggleExpanded(location.id),
                onUndoShipment: (shipment) =>
                    _handleUndoShipment(context, shipment),
              );
            },
          );
        });
  }
}

class LocationShipmentsCard extends StatefulWidget {
  final Location location;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final Function(Shipment) onUndoShipment;

  const LocationShipmentsCard({
    super.key,
    required this.location,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onUndoShipment,
  });

  @override
  State<LocationShipmentsCard> createState() => _LocationShipmentsCardState();
}

class _LocationShipmentsCardState extends State<LocationShipmentsCard> {
  List<Shipment> _shipments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  @override
  void didUpdateWidget(LocationShipmentsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _loadShipments();
    }
  }

  @override
  void dispose() {
    Provider.of<DataProvider>(context, listen: false)
        .stopObservingLocation(widget.location.id);
    super.dispose();
  }

  Future<void> _loadShipments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final shipments = await context
          .read<DataProvider>()
          .getShipmentsByLocation(widget.location.id);

      if (mounted) {
        setState(() {
          _shipments = shipments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading shipments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint.withAlpha(13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildLocationHeader(context),
          if (widget.isExpanded) _buildShipmentsList(context),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    return InkWell(
      onTap: widget.onToggleExpanded,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(12),
        bottom: widget.isExpanded ? Radius.zero : const Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: widget.location.photoUrls != null &&
                      widget.location.photoUrls!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(widget.location.photoUrls!.first),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildLetterAvatar(context),
                      ),
                    )
                  : _buildLetterAvatar(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.location.partieNr,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_shipments.length} ${_shipments.length == 1 ? 'Abfuhr' : 'Abfuhren'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.location.sawmill != null &&
                          widget.location.sawmill!.isNotEmpty)
                        Expanded(
                          child: Text(
                            widget.location.sawmill!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              visualDensity: VisualDensity.compact,
              iconSize: 20,
              tooltip: 'Details anzeigen',
              onPressed: () => _showLocationDetails(context),
            ),
            IconButton(
              icon: Icon(
                  widget.isExpanded ? Icons.expand_less : Icons.expand_more),
              visualDensity: VisualDensity.compact,
              iconSize: 20,
              tooltip: widget.isExpanded ? 'Einklappen' : 'Ausklappen',
              onPressed: widget.onToggleExpanded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentsList(BuildContext context) {
    return StreamBuilder<Map<int, List<Shipment>>>(
      stream: DataProvider.shipmentsByLocationStream,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.containsKey(widget.location.id)) {
          _shipments = snapshot.data![widget.location.id]!;
        }

        if (_isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
          );
        }

        if (_shipments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('Keine Abfuhren gefunden')),
          );
        }

        return Column(
          children: [
            const Divider(height: 1),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _shipments.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 64),
              itemBuilder: (context, index) {
                final shipment = _shipments[index];
                return ShipmentListItem(
                  shipment: shipment,
                  onUndo: () => widget.onUndoShipment(shipment),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLetterAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.location.sawmill != null && widget.location.sawmill!.isNotEmpty
            ? widget.location.sawmill![0].toUpperCase()
            : widget.location.partieNr.isNotEmpty
                ? widget.location.partieNr[0].toUpperCase()
                : '?',
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLocationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LocationDetailsDialog(location: widget.location),
    );
  }
}

class ShipmentListItem extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onUndo;

  const ShipmentListItem({
    super.key,
    required this.shipment,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(77),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateFormat
                        .format(shipment.date)
                        .split('.')
                        .take(2)
                        .join('.'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeFormat.format(shipment.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.primary.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: 'Normal: ${shipment.normalQuantity} fm',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (shipment.oversizeQuantity > 0)
                          TextSpan(
                            text: ' • ÜS: ${shipment.oversizeQuantity} fm',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    child: Row(
                      children: [
                        Text('${shipment.pieceCount} Stück'),
                        const SizedBox(width: 8),
                        if (shipment.sawmill.isNotEmpty) ...[
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(123),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              shipment.sawmill,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (shipment.userId.isNotEmpty && shipment.name != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: Container(
                  height: 28,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shipment.name!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Tooltip(
              message: "Rückgängig machen",
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onUndo,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.undo,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
