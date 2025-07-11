# ht_data_repository

![coverage: percentage](https://img.shields.io/badge/coverage-100-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

A generic repository that acts as an abstraction layer over an `HtDataClient`. It provides standard data access methods (CRUD, querying) for a specific data type `T`, delegating operations to the injected client.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  ht_data_repository:
    git:
      url: https://github.com/headlines-toolkit/ht-data-repository.git
      # Optionally specify a ref (branch, tag, commit hash)
      # ref: main
```

You will also need to include the `ht_data_client` package, which this repository depends on, and potentially `ht_http_client` if you need to handle its specific exceptions.

```yaml
dependencies:
  ht_data_client:
    git:
      url: https://github.com/headlines-toolkit/ht-data-client.git
  ht_http_client: # Needed for handling specific exceptions
    git:
      url: https://github.com/headlines-toolkit/ht-http-client.git
```

## Features

*   **Abstraction:** Provides a clean interface for data operations, hiding the underlying `HtDataClient` implementation details and the `SuccessApiResponse` envelope structure.
*   **User Scoping:** Supports optional user-scoped data operations via a `userId` parameter in all data access methods, allowing for both user-specific and global resource management.
*   **CRUD Operations:** Supports standard Create, Read (`Future<T>`), Update (`Future<T>`), and Delete (`Future<void>`) operations for a generic type `T`. These methods now accept an optional `String? userId`.
*   **Advanced Querying:** A single `readAll` method returns a `Future<PaginatedResponse<T>>` and supports rich filtering, multi-field sorting, and cursor-based pagination, aligning with modern NoSQL database capabilities.
*   **Error Propagation:** Catches and re-throws exceptions (like `HtHttpException` subtypes or `FormatException`) from the data client layer, allowing higher layers to handle them appropriately.
*   **Dependency Injection:** Designed to receive an `HtDataClient<T>` instance via its constructor.

## Usage

Instantiate the repository by providing an implementation of `HtDataClient<T>`.

```dart
import 'package:ht_data_client/ht_data_client.dart';
import 'package:ht_data_repository/ht_data_repository.dart';
import 'package:ht_shared/ht_shared.dart'; // For exception handling

// Define your data model
class MyData {
  final String id;
  final String name;

  MyData({required this.id, required this.name});

  // Add fromJson/toJson if needed by your client implementation
}

// Assume you have an implementation of HtDataClient<MyData>
// (e.g., HtHttpDataClient, MockDataClient, etc.)
late HtDataClient<MyData> myDataClient; // Initialize this appropriately

// Create the repository instance
final myDataRepository = HtDataRepository<MyData>(dataClient: myDataClient);

// Use the repository methods
Future<void> exampleUsage() async {
  const userId = 'example-user-id'; // Example user ID

  try {
    // Create an item for a specific user
    final newItem = MyData(id: 'temp', name: 'New Item');
    final createdItem = await myDataRepository.create(item: newItem, userId: userId);
    print('Created: ${createdItem.id}, ${createdItem.name} for user $userId');

    // Read an item for a specific user
    final readItem = await myDataRepository.read(id: createdItem.id, userId: userId);
    print('Read: ${readItem.id}, ${readItem.name} for user $userId');

    // Read all items for a user with pagination
    final allItemsResponse = await myDataRepository.readAll(
      userId: userId,
      pagination: PaginationOptions(limit: 10),
    );
    print('Read ${allItemsResponse.items.length} items for user $userId.');
    if (allItemsResponse.nextCursor != null) {
      print('More items available (nextCursor: ${allItemsResponse.nextCursor})');
    }

    // Query items for a user with filtering and sorting
    final filter = {'status': 'published'};
    final sort = [SortOption('publishDate', SortOrder.desc)];
    final queriedItemsResponse = await myDataRepository.readAll(
      userId: userId,
      filter: filter,
      sort: sort,
    );
    print('Found ${queriedItemsResponse.items.length} items matching filter for user $userId.');

    // Update an item for a specific user
    final updatedItemData = MyData(id: createdItem.id, name: 'Updated Name');
    final updatedItem = await myDataRepository.update(id: createdItem.id, item: updatedItemData, userId: userId);
    print('Updated: ${updatedItem.id}, ${updatedItem.name} for user $userId');

    // Example of a global read (without userId)
     final PaginatedResponse<MyData> globalItemsResponse =
        await myDataRepository.readAll(pagination: PaginationOptions(limit: 5));
    print('Read ${globalItemsResponse.items.length} global items.');


  } on HtHttpException catch (e) {
    // Handle specific HTTP errors from the client
    // Note: HtHttpException subtypes from ht_shared do not have statusCode
    print('HTTP Error: ${e.message}');
    if (e is NotFoundException) {
      print('Item not found.');
    } else if (e is ForbiddenException) {
      print('Permission denied for this operation.');
    }
  } on FormatException catch (e) {
    // Handle data format errors during deserialization
    print('Data Format Error: $e');
  } catch (e) {
    // Handle other unexpected errors
    print('An unexpected error occurred: $e');
  }
}

```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please review the terms before use.
