import 'dart:async';
import 'dart:convert';

import 'package:authentication_api/authentication_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api/user_api.dart';

/// {@template authentication_local_storage}
/// A flutter implementation of the authentication local storage
/// {@endtemplate}
class AuthenticationLocalStorage extends AuthenticationApi {
  /// {@macro authentication_local_storage}
  AuthenticationLocalStorage({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  // StreamController to broadcast updates on authentication
  final _authenticationStreamController = StreamController<User?>.broadcast();

  /// Stream of authenticated user
  @override
  Stream<User?> getAuthenticatedUser() =>
      _authenticationStreamController.stream;

  static const _authCollectionKey = '__auth_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);

  void _init() {
    final storageData = _getValue(_authCollectionKey);

    if (storageData != null) {
      final userJson = jsonDecode(storageData) as Map<String, dynamic>;

      final user = User.fromJson(userJson);
      _authenticationStreamController.add(user);
    }
  }

  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  @override
  Future<void> addAuthenticatedUser(User user) {
    _authenticationStreamController.add(user);

    return _setValue(_authCollectionKey, json.encode(user));
  }

  @override
  Future<void> removeAuthentication() => _plugin.remove(_authCollectionKey);

  Future<void> _dispose() => _authenticationStreamController.close();

  @override
  Future<void> close() {
    return _dispose();
  }
}
