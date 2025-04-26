//
// ignore_for_file: lines_longer_than_80_chars

import 'package:ht_data_client/ht_data_client.dart';
import 'package:ht_http_client/ht_http_client.dart'
    show BadRequestException, HtHttpException, NotFoundException;

/// {@template ht_data_repository}
/// A generic repository that acts as an abstraction layer over an [HtDataClient].
///
/// It mirrors the data access methods provided by the [HtDataClient] interface
/// (CRUD operations, querying) for a specific data type [T].
///
/// This repository requires an instance of [HtDataClient<T>] to be injected
/// via its constructor. It delegates all data operations to the underlying client.
///
/// Error Handling:
/// The repository catches exceptions thrown by the injected [HtDataClient]
/// (typically subtypes of [HtHttpException] from the network layer, or
/// potentially [FormatException] during deserialization) and re-throws them.
/// This allows higher layers (like BLoCs or API route handlers) to implement
/// specific error handling logic based on the exception type.
/// {@endtemplate}
class HtDataRepository<T> {
  /// {@macro ht_data_repository}
  const HtDataRepository({required HtDataClient<T> dataClient})
      : _dataClient = dataClient;

  final HtDataClient<T> _dataClient;

  /// Creates a new resource item of type [T] by delegating to the client.
  ///
  /// Returns the created item.
  ///
  /// Re-throws any [HtHttpException] or [FormatException] from the client.
  Future<T> create(T item) async {
    try {
      return await _dataClient.create(item);
    } on HtHttpException {
      rethrow; // Propagate client-level HTTP exceptions
    } on FormatException {
      rethrow; // Propagate serialization/deserialization errors
    }
    // Catch-all for unexpected errors, though specific catches are preferred.
    // Consider logging here if necessary.
  }

  /// Reads a single resource item of type [T] by its unique [id] via the client.
  ///
  /// Returns the deserialized item.
  ///
  /// Re-throws any [HtHttpException] (like [NotFoundException]) or
  /// [FormatException] from the client.
  Future<T> read(String id) async {
    try {
      return await _dataClient.read(id);
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Reads all resource items of type [T] via the client.
  ///
  /// Supports pagination using [startAfterId] and [limit].
  /// Returns a list of deserialized items.
  ///
  /// Re-throws any [HtHttpException] or [FormatException] from the client.
  Future<List<T>> readAll({String? startAfterId, int? limit}) async {
    try {
      return await _dataClient.readAll(
        startAfterId: startAfterId,
        limit: limit,
      );
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Reads multiple resource items of type [T] based on a [query] via the client.
  ///
  /// Supports pagination using [startAfterId] and [limit].
  /// Returns a list of deserialized items matching the query.
  ///
  /// Re-throws any [HtHttpException] (like [BadRequestException]) or
  /// [FormatException] from the client.
  Future<List<T>> readAllByQuery(
    Map<String, dynamic> query, {
    String? startAfterId,
    int? limit,
  }) async {
    try {
      return await _dataClient.readAllByQuery(
        query,
        startAfterId: startAfterId,
        limit: limit,
      );
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Updates an existing resource item of type [T] identified by [id] via the client.
  ///
  /// Returns the updated item.
  ///
  /// Re-throws any [HtHttpException] (like [NotFoundException]) or
  /// [FormatException] from the client.
  Future<T> update(String id, T item) async {
    try {
      return await _dataClient.update(id, item);
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Deletes a resource item identified by [id] via the client.
  ///
  /// Returns `void` upon successful deletion.
  ///
  /// Re-throws any [HtHttpException] (like [NotFoundException]) from the client.
  Future<void> delete(String id) async {
    try {
      await _dataClient.delete(id);
    } on HtHttpException {
      rethrow;
    }
  }
}
