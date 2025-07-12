//
// ignore_for_file: lines_longer_than_80_chars

import 'package:ht_data_client/ht_data_client.dart';
import 'package:ht_shared/ht_shared.dart';

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
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// created item of type [T].
  ///
  /// Re-throws any [HtHttpException] or [FormatException] from the client.
  Future<T> create({required T item, String? userId}) async {
    try {
      final response = await _dataClient.create(item: item, userId: userId);
      return response.data;
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
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// deserialized item of type [T].
  ///
  /// Re-throws any [HtHttpException] (like [NotFoundException]) or
  /// [FormatException] from the client.
  Future<T> read({required String id, String? userId}) async {
    try {
      final response = await _dataClient.read(id: id, userId: userId);
      return response.data;
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Reads multiple resource items of type [T] via the client, with support
  /// for rich filtering, sorting, and pagination.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// [PaginatedResponse] containing the list of deserialized items and
  /// pagination details.
  ///
  /// Re-throws any [HtHttpException] or [FormatException] from the client.
  Future<PaginatedResponse<T>> readAll({
    String? userId,
    Map<String, dynamic>? filter,
    PaginationOptions? pagination,
    List<SortOption>? sort,
  }) async {
    try {
      final response = await _dataClient.readAll(
        userId: userId,
        filter: filter,
        pagination: pagination,
        sort: sort,
      );
      return response.data;
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Updates an existing resource item of type [T] identified by [id] via the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// updated item of type [T].
  ///
  /// Re-throws any [HtHttpException] (like [NotFoundException]) or
  /// [FormatException] from the client.
  Future<T> update({
    required String id,
    required T item,
    String? userId,
  }) async {
    try {
      final response = await _dataClient.update(
        id: id,
        item: item,
        userId: userId,
      );
      return response.data;
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
  Future<void> delete({required String id, String? userId}) async {
    try {
      await _dataClient.delete(id: id, userId: userId);
    } on HtHttpException {
      rethrow;
    }
  }

  /// Counts the number of resource items matching the given criteria by
  /// delegating to the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// total count as an integer.
  ///
  /// Re-throws any [HtHttpException] or [FormatException] from the client.
  Future<int> count({
    String? userId,
    Map<String, dynamic>? filter,
  }) async {
    try {
      final response = await _dataClient.count(
        userId: userId,
        filter: filter,
      );
      return response.data;
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Executes a complex aggregation pipeline on the data source by delegating
  /// to the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// resulting list of documents.
  ///
  /// Re-throws any [HtHttpException] or [FormatException] from the client.
  Future<List<Map<String, dynamic>>> aggregate({
    required List<Map<String, dynamic>> pipeline,
    String? userId,
  }) async {
    try {
      final response = await _dataClient.aggregate(
        pipeline: pipeline,
        userId: userId,
      );
      return response.data;
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }
}
