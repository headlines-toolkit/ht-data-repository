//
// ignore_for_file: lines_longer_than_80_chars, avoid_equals_and_hash_code_on_mutable_classes

import 'package:ht_data_client/ht_data_client.dart';
import 'package:ht_data_repository/ht_data_repository.dart';
import 'package:ht_shared/ht_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Define a simple dummy data class for testing the generic repository
class _MockData {
  const _MockData({required this.id, this.value = 'default'});
  final String id;
  final String value;

  // Add equals and hashCode for comparison in tests
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MockData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ value.hashCode;

  @override
  String toString() => '_MockData(id: $id, value: $value)';
}

// Mock the HtDataClient using mocktail
class MockHtDataClient extends Mock implements HtDataClient<_MockData> {}

void main() {
  group('HtDataRepository', () {
    late HtDataClient<_MockData> mockDataClient;
    late HtDataRepository<_MockData> repository;

    // Dummy data instances for testing
    const mockId = 'test-id-123';
    const mockItem = _MockData(id: mockId, value: 'Test Item');
    const mockSuccessResponseItem = SuccessApiResponse(data: mockItem);
    const updatedMockItem = _MockData(id: mockId, value: 'Updated Item');
    const mockSuccessResponseUpdatedItem = SuccessApiResponse(
      data: updatedMockItem,
    );
    final mockItemsList = [
      const _MockData(id: 'id1', value: 'Item 1'),
      const _MockData(id: 'id2', value: 'Item 2'),
    ];
    // Helper for paginated responses
    final mockPaginatedResponse = PaginatedResponse(
      items: mockItemsList,
      cursor: null, // Assuming no cursor for these basic tests
      hasMore: false, // Assuming no more items for these basic tests
    );
    final mockSuccessResponseList = SuccessApiResponse(
      data: mockPaginatedResponse,
    );

    final mockQuery = {'category': 'test'};
    const mockHttpException = NotFoundException('Item not found');
    const mockFormatException = FormatException('Invalid data format');
    const mockSortBy = 'name';
    const mockSortOrder = SortOrder.asc;

    setUp(() {
      // Register fallback values for any() matchers if needed
      registerFallbackValue(const _MockData(id: 'fallback'));
      // Rely on type inference for the map fallback value
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(SortOrder.asc);

      mockDataClient = MockHtDataClient();
      repository = HtDataRepository<_MockData>(dataClient: mockDataClient);
    });

    // --- Test Cases ---

    group('create', () {
      test('should call client.create and return the SuccessApiResponse '
          'containing the created item', () async {
        // Arrange
        when(
          () => mockDataClient.create(
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseItem);

        // Act
        final result = await repository.create(item: mockItem);

        // Assert
        // Repository now returns the unwrapped item
        expect(result, equals(mockItem));
        verify(
          () => mockDataClient.create(item: mockItem, userId: null),
        ).called(1);
      });

      test(
        'should rethrow HtHttpException when client.create throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.create(
              item: any(named: 'item'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockHttpException);

          // Act & Assert
          expect(
            () => repository.create(item: mockItem),
            throwsA(isA<HtHttpException>()),
          );
          verify(
            () => mockDataClient.create(item: mockItem, userId: null),
          ).called(1);
        },
      );

      test(
        'should rethrow FormatException when client.create throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.create(
              item: any(named: 'item'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(
            () => repository.create(item: mockItem),
            throwsA(isA<FormatException>()),
          );
          verify(
            () => mockDataClient.create(item: mockItem, userId: null),
          ).called(1);
        },
      );
    });

    group('read', () {
      test('should call client.read and return the SuccessApiResponse '
          'containing the item', () async {
        // Arrange
        when(
          () => mockDataClient.read(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseItem);

        // Act
        final result = await repository.read(id: mockId);

        // Assert
        // Repository now returns the unwrapped item
        expect(result, equals(mockItem));
        verify(() => mockDataClient.read(id: mockId, userId: null)).called(1);
      });

      test('should rethrow HtHttpException when client.read throws', () async {
        // Arrange
        when(
          () => mockDataClient.read(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(
          () => repository.read(id: mockId),
          throwsA(isA<HtHttpException>()),
        );
        verify(() => mockDataClient.read(id: mockId, userId: null)).called(1);
      });

      test('should rethrow FormatException when client.read throws', () async {
        // Arrange
        when(
          () => mockDataClient.read(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockFormatException);

        // Act & Assert
        expect(
          () => repository.read(id: mockId),
          throwsA(isA<FormatException>()),
        );
        verify(() => mockDataClient.read(id: mockId, userId: null)).called(1);
      });
    });

    group('readAll', () {
      test(
          'should call client.readAll with all args and return PaginatedResponse',
          () async {
        // Arrange
        when(
          () => mockDataClient.readAll(
            userId: any(named: 'userId'),
            startAfterId: any(named: 'startAfterId'),
            limit: any(named: 'limit'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseList);

        // Act
        final result = await repository.readAll(
          startAfterId: 'lastId',
          limit: 10,
          sortBy: mockSortBy,
          sortOrder: mockSortOrder,
        );

        // Assert
        // Repository now returns the unwrapped PaginatedResponse
        expect(result, equals(mockPaginatedResponse));
        expect(result.items, equals(mockItemsList)); // Check items within
        verify(
          () => mockDataClient.readAll(
            userId: null,
            startAfterId: 'lastId',
            limit: 10,
            sortBy: mockSortBy,
            sortOrder: mockSortOrder,
          ),
        ).called(1);
      });

      test('should call client.readAll without pagination args', () async {
        // Arrange
        when(
          () => mockDataClient.readAll(
            userId: any(named: 'userId'),
            startAfterId: any(named: 'startAfterId'),
            limit: any(named: 'limit'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseList);

        // Act
        final result = await repository.readAll();

        // Assert
        // Repository now returns the unwrapped PaginatedResponse
        expect(result, equals(mockPaginatedResponse));
        expect(result.items, equals(mockItemsList)); // Check items within
        verify(
          () => mockDataClient.readAll(
            userId: null,
            startAfterId: null,
            limit: null,
            sortBy: null,
            sortOrder: null,
          ),
        ).called(1);
      });

      test(
        'should rethrow HtHttpException when client.readAll throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.readAll(
              userId: any(named: 'userId'),
              startAfterId: any(named: 'startAfterId'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenThrow(mockHttpException);

          // Act & Assert
          expect(() => repository.readAll(), throwsA(isA<HtHttpException>()));
          verify(
            () => mockDataClient.readAll(
              userId: null,
              startAfterId: null,
              limit: null,
              sortBy: null,
              sortOrder: null,
            ),
          ).called(1);
        },
      );

      test(
        'should rethrow FormatException when client.readAll throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.readAll(
              userId: any(named: 'userId'),
              startAfterId: any(named: 'startAfterId'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(() => repository.readAll(), throwsA(isA<FormatException>()));
          verify(
            () => mockDataClient.readAll(
              userId: null,
              startAfterId: null,
              limit: null,
              sortBy: null,
              sortOrder: null,
            ),
          ).called(1);
        },
      );
    });

    group('readAllByQuery', () {
      test(
          'should call client.readAllByQuery with all args and return PaginatedResponse',
          () async {
        // Arrange
        when(
          () => mockDataClient.readAllByQuery(
            any(),
            userId: any(named: 'userId'),
            startAfterId: any(named: 'startAfterId'),
            limit: any(named: 'limit'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseList);

        // Act
        final result = await repository.readAllByQuery(
          mockQuery,
          startAfterId: 'lastId',
          limit: 10,
          sortBy: mockSortBy,
          sortOrder: mockSortOrder,
        );

        // Assert
        // Repository now returns the unwrapped PaginatedResponse
        expect(result, equals(mockPaginatedResponse));
        expect(result.items, equals(mockItemsList)); // Check items within
        verify(
          () => mockDataClient.readAllByQuery(
            mockQuery,
            userId: null,
            startAfterId: 'lastId',
            limit: 10,
            sortBy: mockSortBy,
            sortOrder: mockSortOrder,
          ),
        ).called(1);
      });

      test(
        'should call client.readAllByQuery without pagination args',
        () async {
          // Arrange
          when(
            () => mockDataClient.readAllByQuery(
              any(),
              userId: any(named: 'userId'),
              startAfterId: any(named: 'startAfterId'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer((_) async => mockSuccessResponseList);

          // Act
          final result = await repository.readAllByQuery(mockQuery);

          // Assert
          // Repository now returns the unwrapped PaginatedResponse
          expect(result, equals(mockPaginatedResponse));
          expect(result.items, equals(mockItemsList)); // Check items within
          verify(
            () => mockDataClient.readAllByQuery(
              mockQuery,
              userId: null,
              startAfterId: null,
              limit: null,
              sortBy: null,
              sortOrder: null,
            ),
          ).called(1);
        },
      );

      test(
        'should rethrow HtHttpException when client.readAllByQuery throws',
        () async {
          // Arrange
          const badRequestException = BadRequestException('Invalid query');
          when(
            () => mockDataClient.readAllByQuery(
              any(),
              userId: any(named: 'userId'),
              startAfterId: any(named: 'startAfterId'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenThrow(badRequestException);

          // Act & Assert
          expect(
            () => repository.readAllByQuery(mockQuery),
            throwsA(isA<HtHttpException>()),
          );
          verify(
            () => mockDataClient.readAllByQuery(
              mockQuery,
              userId: null,
              startAfterId: null,
              limit: null,
              sortBy: null,
              sortOrder: null,
            ),
          ).called(1);
        },
      );

      test(
        'should rethrow FormatException when client.readAllByQuery throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.readAllByQuery(
              any(),
              userId: any(named: 'userId'),
              startAfterId: any(named: 'startAfterId'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(
            () => repository.readAllByQuery(mockQuery),
            throwsA(isA<FormatException>()),
          );
          verify(
            () => mockDataClient.readAllByQuery(
              mockQuery,
              userId: null,
              startAfterId: null,
              limit: null,
              sortBy: null,
              sortOrder: null,
            ),
          ).called(1);
        },
      );
    });

    group('update', () {
      test('should call client.update and return the SuccessApiResponse '
          'containing the updated item', () async {
        // Arrange
        when(
          () => mockDataClient.update(
            id: any(named: 'id'),
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseUpdatedItem);

        // Act
        final result = await repository.update(id: mockId, item: mockItem);

        // Assert
        // Repository now returns the unwrapped item
        expect(result, equals(updatedMockItem));
        verify(
          () => mockDataClient.update(id: mockId, item: mockItem, userId: null),
        ).called(1);
      });

      test(
        'should rethrow HtHttpException when client.update throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.update(
              id: any(named: 'id'),
              item: any(named: 'item'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockHttpException);

          // Act & Assert
          expect(
            () => repository.update(id: mockId, item: mockItem),
            throwsA(isA<HtHttpException>()),
          );
          verify(
            () =>
                mockDataClient.update(id: mockId, item: mockItem, userId: null),
          ).called(1);
        },
      );

      test(
        'should rethrow FormatException when client.update throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.update(
              id: any(named: 'id'),
              item: any(named: 'item'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(
            () => repository.update(id: mockId, item: mockItem),
            throwsA(isA<FormatException>()),
          );
          verify(
            () =>
                mockDataClient.update(id: mockId, item: mockItem, userId: null),
          ).called(1);
        },
      );
    });

    group('delete', () {
      test('should call client.delete', () async {
        // Arrange
        when(
          () => mockDataClient.delete(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async {}); // Completes normally

        // Act
        await repository.delete(id: mockId);

        // Assert
        verify(() => mockDataClient.delete(id: mockId)).called(1);
      });

      test(
        'should rethrow HtHttpException when client.delete throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.delete(
              id: any(named: 'id'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockHttpException);

          // Act & Assert
          expect(
            () => repository.delete(id: mockId),
            throwsA(isA<HtHttpException>()),
          );
          verify(() => mockDataClient.delete(id: mockId)).called(1);
        },
      );

      // Note: delete typically doesn't involve FormatException unless the client
      // implementation has unusual behavior, so we omit that test case here.
    });
  });
}
