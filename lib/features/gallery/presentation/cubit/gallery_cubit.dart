import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/features/gallery/domain/usecases/gallery_usecases.dart';

const maxGalleryUploadsPerUser = 20;

class GalleryState extends Equatable {
  const GalleryState({this.isLoading = false, this.feed, this.error, this.isUploading = false, this.uploadError});
  final bool isLoading;
  final GalleryFeed? feed;
  final Failure? error;
  final bool isUploading;
  final Failure? uploadError;

  GalleryState copyWith({
    bool? isLoading,
    GalleryFeed? feed,
    Failure? error,
    bool clearError = false,
    bool? isUploading,
    Failure? uploadError,
    bool clearUploadError = false,
  }) {
    return GalleryState(
      isLoading: isLoading ?? this.isLoading,
      feed: feed ?? this.feed,
      error: clearError ? null : (error ?? this.error),
      isUploading: isUploading ?? this.isUploading,
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
    );
  }

  @override
  List<Object?> get props => [isLoading, feed, error, isUploading, uploadError];
}

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit(this._getGalleryUseCase, this._uploadUseCase, this._markReadUseCase) : super(const GalleryState());
  final GetGalleryUseCase _getGalleryUseCase;
  final UploadGalleryItemUseCase _uploadUseCase;
  final MarkNotificationReadUseCase _markReadUseCase;

  int uploadedCountFor(String userId) =>
      state.feed?.items.where((item) => item.userId == userId && !item.isAnnouncement).length ?? 0;

  Future<void> load({String? governorate}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final response = await _getGalleryUseCase(governorate: governorate);
    if (response.failure != null) {
      emit(state.copyWith(isLoading: false, error: response.failure));
      return;
    }
    emit(state.copyWith(isLoading: false, feed: response.feed));
  }

  Future<void> upload({
    required String userId,
    required String squadId,
    required String governorate,
    required String url,
    String? caption,
  }) async {
    if (uploadedCountFor(userId) >= maxGalleryUploadsPerUser) {
      emit(state.copyWith(uploadError: const ValidationFailure(code: 'GALLERY_UPLOAD_LIMIT')));
      return;
    }
    emit(state.copyWith(isUploading: true, clearUploadError: true));
    final response = await _uploadUseCase(
      userId: userId,
      squadId: squadId,
      governorate: governorate,
      type: 'image',
      url: url,
      caption: caption,
    );
    if (response.failure != null) {
      emit(state.copyWith(isUploading: false, uploadError: response.failure));
      return;
    }
    emit(state.copyWith(isUploading: false));
    await load(governorate: governorate);
  }

  Future<void> markAnnouncementRead(String notificationId, String userId) async {
    if (notificationId.isEmpty) return;
    await _markReadUseCase(notificationId: notificationId, userId: userId);
  }
}
