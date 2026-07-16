import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/models/chat/chat_models.dart';
import 'package:mobile_app/models/common/api_error.dart';
import 'package:mobile_app/models/reviewer/reviewer_models.dart';
import 'package:mobile_app/providers/reviewer_provider.dart';
import 'package:mobile_app/repositories/reviewer_repository.dart';

class MockReviewerRepository extends Mock implements ReviewerRepository {}

ReviewerSubmittedTaskModel _submittedTask(String id) =>
    ReviewerSubmittedTaskModel(
      id: id,
      projectId: 'project-1',
      projectName: 'Project 1',
      annotatorId: 'annotator-1',
      annotatorName: 'Annotator',
      annotationSetId: 'set-1',
      submittedAt: DateTime(2026, 1, 1),
      annotationCount: 2,
      status: 'Submitted',
    );

void main() {
  late MockReviewerRepository mockRepository;
  late ReviewerProvider provider;

  setUp(() {
    mockRepository = MockReviewerRepository();
    provider = ReviewerProvider(repository: mockRepository);
  });

  group('ReviewerProvider', () {
    test('initializes with empty data', () {
      expect(provider.projects, isEmpty);
      expect(provider.tasks, isEmpty);
      expect(provider.projectsState, ReviewerLoadState.initial);
    });

    test('fetchProjects updates loaded state', () async {
      final projects = [
        MyProjectSummaryModel(
          id: 'p1',
          name: 'Project 1',
          todoTaskCount: 3,
          doneTaskCount: 0,
        ),
      ];

      when(() => mockRepository.getProjects()).thenAnswer((_) async => projects);

      await provider.fetchProjects();

      expect(provider.projectsState, ReviewerLoadState.loaded);
      expect(provider.projects, projects);
    });

    test('fetchSubmittedTasks stores error message on failure', () async {
      when(
        () => mockRepository.getSubmittedTasks(projectId: any(named: 'projectId')),
      ).thenThrow(ApiError(message: 'Server error', code: 'HTTP_500'));

      await provider.fetchSubmittedTasks(projectId: 'p1');

      expect(provider.listState, ReviewerLoadState.error);
      expect(provider.errorMessage, 'Server error');
    });

    test('approveTask returns true when repository succeeds', () async {
      when(
        () => mockRepository.approveTask(
          'task-1',
          score: any(named: 'score'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => true);

      final ok = await provider.approveTask(
        'task-1',
        score: 100,
        comment: 'Looks good',
      );

      expect(ok, isTrue);
      expect(provider.isSubmitting, isFalse);
    });

    test('returnTask requires repository call with feedback', () async {
      when(
        () => mockRepository.returnTask(
          'task-1',
          feedback: any(named: 'feedback'),
          score: any(named: 'score'),
          errorTypeIds: any(named: 'errorTypeIds'),
        ),
      ).thenAnswer((_) async => true);

      final ok = await provider.returnTask(
        'task-1',
        feedback: 'Fix bounding boxes',
        score: 0,
      );

      expect(ok, isTrue);
      verify(
        () => mockRepository.returnTask(
          'task-1',
          feedback: 'Fix bounding boxes',
          score: 0,
          errorTypeIds: null,
        ),
      ).called(1);
    });

    test('fetchSubmittedTasks loads task list for project', () async {
      final tasks = [_submittedTask('task-1')];

      when(
        () => mockRepository.getSubmittedTasks(projectId: 'p1'),
      ).thenAnswer((_) async => tasks);

      await provider.fetchSubmittedTasks(projectId: 'p1');

      expect(provider.listState, ReviewerLoadState.loaded);
      expect(provider.tasks, tasks);
      expect(provider.selectedProjectId, 'p1');
    });
  });
}
