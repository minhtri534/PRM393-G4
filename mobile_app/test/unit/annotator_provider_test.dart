import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/utils/annotator_task_filters.dart';
import 'package:mobile_app/models/annotator/annotator_models.dart';
import 'package:mobile_app/models/chat/chat_models.dart';
import 'package:mobile_app/models/common/api_error.dart';
import 'package:mobile_app/providers/annotator_provider.dart';
import 'package:mobile_app/repositories/annotator_repository.dart';

class MockAnnotatorRepository extends Mock implements AnnotatorRepository {}

AnnotatorTaskModel _task(String id, String status) => AnnotatorTaskModel(
      id: id,
      projectId: 'project-1',
      dataItemId: 'item-1',
      status: status,
    );

void main() {
  late MockAnnotatorRepository mockRepository;
  late AnnotatorProvider provider;

  setUp(() {
    mockRepository = MockAnnotatorRepository();
    provider = AnnotatorProvider(repository: mockRepository);
  });

  group('AnnotatorTaskFilters', () {
    test('separates todo and done tasks', () {
      final tasks = [
        _task('1', AppConstants.taskStatusAssigned),
        _task('2', AppConstants.taskStatusSubmitted),
        _task('3', AppConstants.taskStatusReturned),
      ];

      expect(AnnotatorTaskFilters.countTodo(tasks), 2);
      expect(AnnotatorTaskFilters.countDone(tasks), 1);
      expect(
        AnnotatorTaskFilters.filterByTab(tasks, showTodo: true).length,
        2,
      );
    });
  });

  group('AnnotatorProvider', () {
    test('initializes with empty data', () {
      expect(provider.tasks, isEmpty);
      expect(provider.listState, AnnotatorLoadState.initial);
      expect(provider.isListLoading, isFalse);
    });

    test('fetchProjects updates loaded state', () async {
      final projects = [
        MyProjectSummaryModel(
          id: 'p1',
          name: 'Project 1',
          todoTaskCount: 2,
          doneTaskCount: 1,
        ),
      ];

      when(() => mockRepository.getProjects()).thenAnswer((_) async => projects);

      await provider.fetchProjects();

      expect(provider.projectsState, AnnotatorLoadState.loaded);
      expect(provider.projects, projects);
    });

    test('fetchTasks stores error message on failure', () async {
      when(() => mockRepository.getTasks(projectId: any(named: 'projectId')))
          .thenThrow(ApiError(message: 'Network error', code: 'NET'));

      await provider.fetchTasks();

      expect(provider.listState, AnnotatorLoadState.error);
      expect(provider.errorMessage, 'Network error');
    });

    test('acceptTask updates task status locally', () async {
      when(() => mockRepository.getTasks(projectId: any(named: 'projectId')))
          .thenAnswer((_) async => [_task('task-1', AppConstants.taskStatusAssigned)]);
      when(() => mockRepository.acceptTask('task-1')).thenAnswer((_) async => true);

      await provider.fetchTasks();
      final ok = await provider.acceptTask('task-1');

      expect(ok, isTrue);
      expect(provider.tasks.first.status, AppConstants.taskStatusInProgress);
    });
  });
}
