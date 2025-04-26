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

*   **Abstraction:** Provides a clean interface for data operations, hiding the underlying `HtDataClient` implementation details.
*   **CRUD Operations:** Supports standard Create, Read, Update, and Delete operations for a generic type `T`.
*   **Querying:** Allows reading multiple items based on a query map, with support for pagination.
*   **Error Propagation:** Catches and re-throws exceptions (like `HtHttpException` subtypes or `FormatException`) from the data client layer, allowing higher layers to handle them appropriately.
*   **Dependency Injection:** Designed to receive an `HtDataClient<T>` instance via its constructor.

## Usage

Instantiate the repository by providing an implementation of `HtDataClient<T>`.

```dart
import 'package:ht_data_client/ht_data_client.dart';
import 'package:ht_data_repository/ht_data_repository.dart';
import 'package:ht_http_client/ht_http_client.dart'; // For exception handling

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
  try {
    // Create an item
    final newItem = MyData(id: 'temp', name: 'New Item');
    final createdItem = await myDataRepository.create(newItem);
    print('Created: ${createdItem.id}, ${createdItem.name}');

    // Read an item
    final readItem = await myDataRepository.read(createdItem.id);
    print('Read: ${readItem.id}, ${readItem.name}');

    // Read all items (example with pagination)
    final allItems = await myDataRepository.readAll(limit: 10);
    print('Read ${allItems.length} items');

    // Query items
    final query = {'name': 'Specific Item'};
    final queriedItems = await myDataRepository.readAllByQuery(query);
    print('Found ${queriedItems.length} items matching query');

    // Update an item
    final updatedItemData = MyData(id: createdItem.id, name: 'Updated Name');
    final updatedItem = await myDataRepository.update(createdItem.id, updatedItemData);
    print('Updated: ${updatedItem.id}, ${updatedItem.name}');

    // Delete an item
    await myDataRepository.delete(createdItem.id);
    print('Deleted item ${createdItem.id}');

  } on HtHttpException catch (e) {
    // Handle specific HTTP errors from the client
    print('HTTP Error: ${e.statusCode} - ${e.message}');
    if (e is NotFoundException) {
      print('Item not found.');
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
