import 'package:bloc_test/bloc_test.dart';
import 'package:cherry/cubits/base/index.dart';
import 'package:cherry/cubits/index.dart';
import 'package:cherry/repositories-cubit/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'helpers/hydrated.dart';

class MockChangelogRepository extends Mock implements ChangelogRepository {}

void main() {
  initHydratedBloc();
  group('ChangelogCubit', () {
    ChangelogCubit cubit;
    MockChangelogRepository repository;

    setUp(() {
      repository = MockChangelogRepository();
      cubit = ChangelogCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('fails when null service is provided', () {
      expect(() => ChangelogCubit(null), throwsAssertionError);
    });

    test('initial state is RequestState.init()', () {
      expect(cubit.state, RequestState<String>.init());
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        expect(
          cubit.fromJson(cubit.toJson(cubit.state)),
          cubit.state,
        );
      });
    });

    group('fetchData', () {
      blocTest<ChangelogCubit, RequestState>(
        'fetches data correctly',
        build: () {
          when(repository.fetchData()).thenAnswer(
            (_) => Future.value('Lorem'),
          );
          return cubit;
        },
        act: (cubit) async => cubit.loadData(),
        verify: (_) => verify(repository.fetchData()).called(1),
        expect: [
          RequestState<String>.loading(),
          RequestState<String>.loaded('Lorem'),
        ],
      );

      blocTest<ChangelogCubit, RequestState>(
        'can throw an exception',
        build: () {
          when(repository.fetchData()).thenThrow(Exception('wtf'));
          return cubit;
        },
        act: (cubit) async => cubit.loadData(),
        verify: (_) => verify(repository.fetchData()).called(1),
        expect: [
          RequestState<String>.loading(),
          RequestState<String>.error(Exception('wtf').toString()),
        ],
      );
    });
  });
}
