import 'package:myboss_mobile/features/survey/data/survey_draft_store.dart';
import 'package:myboss_mobile/features/survey/domain/usecases/survey_usecases.dart';

/// Flushes offline survey submissions when the device is back online.
class SurveyOfflineSync {
  SurveyOfflineSync(this._store, this._submitResponseUseCase);

  final SurveyDraftStore _store;
  final SubmitSurveyResponseUseCase _submitResponseUseCase;

  Future<int> flushPending({String? userId}) async {
    final pending = await _store.listPending();
    if (pending.isEmpty) return 0;

    final remaining = <SurveyPendingSubmission>[];
    var submitted = 0;

    for (final item in pending) {
      if (userId != null && userId.isNotEmpty && item.userId != userId) {
        remaining.add(item);
        continue;
      }

      final response = await _submitResponseUseCase(
        surveyId: item.surveyId,
        squadId: item.squadId,
        userId: item.userId,
        governorate: item.governorate,
        answers: item.answerPayload,
        anonymous: item.anonymous,
      );

      if (response.failure != null) {
        remaining.add(item);
        continue;
      }

      submitted += 1;
      await _store.clearProgress(userId: item.userId, segment: item.segment);
    }

    await _store.savePendingList(remaining);
    return submitted;
  }
}
