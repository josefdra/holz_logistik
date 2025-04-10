import 'dart:async';
import 'dart:convert';

import 'package:holz_logistik_backend/api/authentication_api.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _authCollectionKey = '__auth_collection_key__';
  final SharedPreferences _plugin;

  // StreamController to broadcast updates on authentication
  final _authenticationStreamController =
      BehaviorSubject<User>.seeded(User.empty());

  /// Stream of authenticated user
  @override
  Stream<User> get authenticatedUser => _authenticationStreamController.stream;

  /// Authenticated user
  @override
  User get currentUser => getUser();

  String? _getValue(String key) => _plugin.getString(key);

  void _init() {
    final storageData = _getValue(_authCollectionKey);

    if (storageData != null) {
      final userJson = jsonDecode(storageData) as Map<String, dynamic>;

      final user = User.fromJson(userJson);
      _authenticationStreamController.add(user);
    } else {
      final user = User.empty();
      _authenticationStreamController.add(user);
    }
  }

  /// Gets the current authenticated user. Returns an emtpy new user if empty.
  User getUser() {
    final storageData = _getValue(_authCollectionKey);

    if (storageData != null) {
      final userJson = jsonDecode(storageData) as Map<String, dynamic>;

      return User.fromJson(userJson);
    } else {
      return User.empty();
    }
  }

  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  @override
  Future<void> updateAuthentication(User user) {
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
