import 'package:holz_logistik_backend/api/user_api.dart';

/// {@template authentication_api}
/// A dart implementation of the authentication api
/// {@endtemplate}
abstract class AuthenticationApi {
  /// {@macro authentication_api}
  const AuthenticationApi();

  /// Provides a [Stream] of the current authenticated user.
  /// 
  /// Will return null if unauthenticated
  Stream<User> get authenticatedUser;

  /// Provides the current authenticated user.
  Future<User> get currentUser;

  /// Provides the api key.
  Future<String> get apiKey;

  /// Adds the authentication of [user].
  Future<void> updateAuthentication(User user);

  /// Sets the api key.
  Future<void> setApiKey(String apiKey);

  /// Removes the authenticated `user`.
  Future<void> removeAuthentication();

  /// Closes the client and frees up any resources.
  Future<void> close();
}
