import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ketchapp_flutter/services/api_service.dart';
import 'api_profile_event.dart';
import 'api_profile_state.dart';

class ApiProfileBloc extends Bloc<ApiProfileEvent, ApiProfileState> {
  final ApiService _apiService;
  final ImagePicker _imagePicker;

  ApiProfileBloc({
    required ApiService apiService,
    required ImagePicker imagePicker,
  }) : _apiService = apiService,
       _imagePicker = imagePicker,
       super(ApiProfileInitial()) {
    on<LoadApiProfile>(_onLoadProfile);
    on<ApiProfileImagePickRequested>(_onProfileImagePickRequested);
    on<ApiProfileImageUploadRequested>(_onProfileImageUploadRequested);
    on<ApiProfileImageDeleteRequested>(_onProfileImageDeleteRequested);
  }

  Future<void> _onLoadProfile(
    LoadApiProfile event,
    Emitter<ApiProfileState> emit,
  ) async {
    try {
      emit(ApiProfileLoading());
      final userData = await _apiService.getCurrentUser();
      final userAchievements = await _apiService.getUserAchievements();

      emit(
        ApiProfileLoaded(userData: userData, allAchievements: userAchievements),
      );
    } catch (e) {
      emit(
        ApiProfileError('Errore nel caricamento del profilo: ${e.toString()}'),
      );
    }
  }

  Future<void> _onProfileImagePickRequested(
    ApiProfileImagePickRequested event,
    Emitter<ApiProfileState> emit,
  ) async {
    if (state is ApiProfileLoaded) {
      final currentState = state as ApiProfileLoaded;
      emit(
        currentState.copyWith(
          isUploadingImage: true,
          clearLocalPreviewFile: true,
        ),
      );
      try {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: event.source,
          imageQuality: 70,
          maxWidth: 800,
        );
        if (pickedFile != null) {
          add(ApiProfileImageUploadRequested(File(pickedFile.path)));
        } else {
          emit(
            currentState.copyWith(
              isUploadingImage: false,
              clearLocalPreviewFile: true,
            ),
          );
        }
      } catch (e) {
        emit(
          ApiProfileError(
            'Errore durante la selezione dell\'immagine: ${e.toString()}',
          ),
        );
        emit(
          currentState.copyWith(
            isUploadingImage: false,
            clearLocalPreviewFile: true,
          ),
        );
      }
    }
  }

  Future<void> _onProfileImageUploadRequested(
    ApiProfileImageUploadRequested event,
    Emitter<ApiProfileState> emit,
  ) async {
    if (state is ApiProfileLoaded) {
      final currentState = state as ApiProfileLoaded;
      try {
        final userUuid = currentState.userData['id'];
        // Chiamata API custom per upload immagine profilo
        final response = await _apiService.postData(
          'users/$userUuid/profile-picture',
          {'filePath': event.imageFile.path},
        );
        emit(
          currentState.copyWith(
            userData: response,
            isUploadingImage: false,
            clearLocalPreviewFile: true,
          ),
        );
        emit(const ApiProfileUpdateSuccess('Immagine del profilo aggiornata.'));
      } catch (e) {
        emit(ApiProfileError('Errore durante il caricamento: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    }
  }

  Future<void> _onProfileImageDeleteRequested(
    ApiProfileImageDeleteRequested event,
    Emitter<ApiProfileState> emit,
  ) async {
    if (state is ApiProfileLoaded) {
      final currentState = state as ApiProfileLoaded;
      emit(currentState.copyWith(isUploadingImage: true));
      try {
        final userUuid = currentState.userData['id'];
        // Chiamata API custom per eliminare immagine profilo
        final response = await _apiService.deleteData(
          'users/$userUuid/profile-picture',
        );
        emit(
          currentState.copyWith(userData: response, isUploadingImage: false),
        );
        emit(const ApiProfileUpdateSuccess('Immagine del profilo eliminata.'));
      } catch (e) {
        emit(
          ApiProfileError('Errore durante l\'eliminazione: ${e.toString()}'),
        );
        emit(currentState.copyWith(isUploadingImage: false));
      }
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
