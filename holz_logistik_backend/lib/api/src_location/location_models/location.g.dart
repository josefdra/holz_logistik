// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      id: json['id'] as String,
      done: json['done'] as bool,
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      partieNr: json['partieNr'] as String,
      additionalInfo: json['additionalInfo'] as String,
      initialQuantity: (json['initialQuantity'] as num).toDouble(),
      initialOversizeQuantity:
          (json['initialOversizeQuantity'] as num).toDouble(),
      initialPieceCount: (json['initialPieceCount'] as num).toInt(),
      currentQuantity: (json['currentQuantity'] as num).toDouble(),
      currentOversizeQuantity:
          (json['currentOversizeQuantity'] as num).toDouble(),
      currentPieceCount: (json['currentPieceCount'] as num).toInt(),
      contract: Contract.fromJson(json['contract'] as Map<String, dynamic>),
      sawmills: (json['sawmills'] as List<dynamic>)
          .map((e) => Sawmill.fromJson(e as Map<String, dynamic>))
          .toList(),
      oversizeSawmills: (json['oversizeSawmills'] as List<dynamic>)
          .map((e) => Sawmill.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      shipments: (json['shipments'] as List<dynamic>)
          .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'id': instance.id,
      'done': instance.done,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'partieNr': instance.partieNr,
      'additionalInfo': instance.additionalInfo,
      'initialQuantity': instance.initialQuantity,
      'initialOversizeQuantity': instance.initialOversizeQuantity,
      'initialPieceCount': instance.initialPieceCount,
      'currentQuantity': instance.currentQuantity,
      'currentOversizeQuantity': instance.currentOversizeQuantity,
      'currentPieceCount': instance.currentPieceCount,
      'contract': instance.contract,
      'sawmills': instance.sawmills,
      'oversizeSawmills': instance.oversizeSawmills,
      'photos': instance.photos,
      'shipments': instance.shipments,
    };
