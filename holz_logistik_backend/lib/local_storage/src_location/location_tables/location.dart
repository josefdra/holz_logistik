import 'package:holz_logistik_backend/local_storage/contract_local_storage.dart';

/// Provides constants and utilities for working with
/// the "locations" database table.
class LocationTable {
  /// The name of the database table
  static const String tableName = 'locations';

  /// The column name for the primary key identifier of a location.
  static const String columnId = 'id';

  /// The column name for the done status of the location.
  static const String columnDone = 'done';

  /// The column name for the timestamp when a location was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for latitude of the location.
  static const String columnLatitude = 'latitude';

  /// The column name for longitude of the location.
  static const String columnLongitude = 'longitude';

  /// The column name for storing the partie number of the location.
  static const String columnPartieNr = 'partieNr';

  /// The column name for storing additional information of the location.
  static const String columnAdditionalInfo = 'additionalInfo';

  /// The column name for storing the initial quantity of the location.
  static const String columnInitialQuantity = 'initialQuantity';

  /// The column name for storing the initial oversize quantity of the location.
  static const String columnInitialOversizeQuantity = 'initialOversizeQuantity';

  /// The column name for storing the initial piece count of the location.
  static const String columnInitialPieceCount = 'initialPieceCount';

  /// The column name for storing the current quantity of the location.
  static const String columnCurrentQuantity = 'currentQuantity';

  /// The column name for storing the current oversize quantity of the location.
  static const String columnCurrenOversizeQuantity = 'currentOversizeQuantity';

  /// The column name for storing the current piece count of the location.
  static const String columnCurrentPieceCount = 'currentPieceCount';

  /// The column name for storing the contract id of the location.
  static const String columnContractId = 'contractId';

  /// SQL statement for creating the locations table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnDone INTEGER NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnPartieNr TEXT NOT NULL,
      $columnAdditionalInfo TEXT NOT NULL,
      $columnInitialQuantity REAL NOT NULL,
      $columnInitialOversizeQuantity REAL NOT NULL,
      $columnInitialPieceCount INTEGER NOT NULL,
      $columnCurrentQuantity REAL NOT NULL,
      $columnCurrenOversizeQuantity REAL NOT NULL,
      $columnCurrentPieceCount INTEGER NOT NULL,
      $columnContractId TEXT NOT NULL,
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId})
    )
  ''';
}
