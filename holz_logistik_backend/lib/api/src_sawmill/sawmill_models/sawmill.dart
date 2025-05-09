import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'sawmill.g.dart';

/// Mixin that implements the [Gettable] interface for Sawmill objects
/// Maps specific sawmill properties to standard sortable properties
mixin SawmillSortGettable implements Gettable {
  /// Original sawmill date
  DateTime get lastEdit;
  
  /// Original sawmill name
  @override
  String get name;
  
  /// Maps [lastEdit] to the standardized [date] property
  @override
  DateTime get date => lastEdit;
}

/// {@template sawmill_item}
/// A single `sawmill` item.
///
/// Contains a [id], time of the [lastEdit] and [name].
///
/// [Sawmill]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Sawmill extends Equatable with SawmillSortGettable {
  /// {@macro sawmill_item}
  Sawmill({
    String? id,
    DateTime? lastEdit,
    this.name = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  /// The id of the `sawmill`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `sawmill` was last modified.
  ///
  /// Cannot be empty.
  @override
  @DateTimeConverter()
  final DateTime lastEdit;

  /// The name of the `sawmill`.
  ///
  /// Cannot be empty.
  @override
  final String name;

  /// Returns a copy of this `sawmill` with the given values updated.
  ///
  /// {@macro sawmill_item}
  Sawmill copyWith({
    String? id,
    DateTime? lastEdit,
    String? name,
  }) {
    return Sawmill(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      name: name ?? this.name,
    );
  }

  /// Deserializes the given [JsonMap] into a [Sawmill].
  static Sawmill fromJson(JsonMap json) => _$SawmillFromJson(json);

  /// Converts this [Sawmill] into a [JsonMap].
  JsonMap toJson() => _$SawmillToJson(this);

  @override
  List<Object> get props => [id, lastEdit, name];
}
