import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/api/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

/// Defines the possible roles a user can have
@JsonEnum(valueField: 'value')
enum Role {
  /// Basic user (regular permissions)
  basic(0),

  /// Privileged user (edit permission for contracts and locations)
  privileged(1),

  /// Admin user (administrative permissions)
  admin(2);

  /// Constructor with integer value
  const Role(this.value);

  /// Integer value of the role
  final int value;

  /// Get Role from integer value
  static Role fromValue(int value) {
    return Role.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Role.basic,
    );
  }
}

/// {@template user_item}
/// A single `user` item.
///
/// Contains a [id], [role], time of the [lastEdit] and [name].
///
/// [User]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class User extends Equatable {
  /// {@macro user_item}
  const User({
    required this.id,
    required this.role,
    required this.lastEdit,
    required this.name,
  });

  /// {@macro user_item}
  User.empty({
    String? id,
    this.role = Role.basic,
    DateTime? lastEdit,
    this.name = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  /// The id of the `user`.
  ///
  /// Cannot be empty.
  final String id;

  /// The `user`role.
  ///
  /// Cannot be empty.
  final Role role;

  /// The time the `user` was last modified.
  ///
  /// Cannot be empty.
  final DateTime lastEdit;

  /// The name of the `user`.
  ///
  /// Cannot be empty.
  final String name;

  /// Returns a copy of this `user` with the given values updated.
  ///
  /// {@macro user_item}
  User copyWith({
    String? id,
    Role? role,
    DateTime? lastEdit,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      lastEdit: lastEdit ?? this.lastEdit,
      name: name ?? this.name,
    );
  }

  /// Deserializes the given [JsonMap] into a [User].
  static User fromJson(JsonMap json) => _$UserFromJson(json);

  /// Converts this [User] into a [JsonMap].
  JsonMap toJson() => _$UserToJson(this);

  @override
  List<Object> get props => [id, role, lastEdit, name];
}
