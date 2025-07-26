import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ketchapp_flutter/features/auth/bloc/api_auth_bloc.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'api_profile_event.dart';
import 'api_profile_state.dart';

class ApiProfileBloc extends Bloc<ApiProfileEvent, ApiProfileState> {
  final ApiService _apiService;
  final ApiAuthBloc _apiAuthBloc;
  final ImagePicker _imagePicker;
  StreamSubscription? _authSubscription;

  ApiProfileBloc({
    required ApiService apiService,
    required ApiAuthBloc apiAuthBloc,
    required ImagePicker imagePicker,
  })  : _apiService = apiService,
        _apiAuthBloc = apiAuthBloc,
        _imagePicker = imagePicker,
        super(ApiProfileInitial()) {
    _authSubscription = _apiAuthBloc.stream.listen((state) {
      if (state is ApiAuthenticated) {
        add(LoadApiProfile());
      }
    });

    on<LoadApiProfile>(_onLoadProfile);
    on<ApiProfileImagePickRequested>(_onProfileImagePickRequested);
    on<ApiProfileImageUploadRequested>(_onProfileImageUploadRequested);
    on<ApiProfileImageDeleteRequested>(_onProfileImageDeleteRequested);
  }

  Future<void> _onLoadProfile(
      LoadApiProfile event, Emitter<ApiProfileState> emit) async {
    final authState = _apiAuthBloc.state;
    if (authState is ApiAuthenticated) {
      try {
        emit(ApiProfileLoading());
        final userUuid = authState.userData['uuid'];
        final userData = await _apiService.fetchData('users/$userUuid');
        final allAchievements = await _apiService.getAllAchievements();
        final completedAchievements = await _apiService.getUserAchievements(userUuid);

        emit(ApiProfileLoaded(
          userData: userData,
          allAchievements: allAchievements,
          completedAchievementTitles: completedAchievements.map((a) => a.title).toSet(),
        ));
      } catch (e) {
        emit(ApiProfileError('Errore nel caricamento del profilo: ${e.toString()}'));
      }
    }
  }

  Future<void> _onProfileImagePickRequested(
      ApiProfileImagePickRequested event, Emitter<ApiProfileState> emit) async {
    if (state is ApiProfileLoaded) {
      final currentState = state as ApiProfileLoaded;
      emit(currentState.copyWith(isUploadingImage: true, clearLocalPreviewFile: true));
      try {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: event.source,
          imageQuality: 70,
          maxWidth: 800,
        );
        if (pickedFile != null) {
          add(ApiProfileImageUploadRequested(File(pickedFile.path)));
        } else {
          emit(currentState.copyWith(isUploadingImage: false, clearLocalPreviewFile: true));
        }
      } catch (e) {
        emit(ApiProfileError('Errore durante la selezione dell\'immagine: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false, clearLocalPreviewFile: true));
      }
    }
  }

  Future<void> _onProfileImageUploadRequested(
      ApiProfileImageUploadRequested event, Emitter<ApiProfileState> emit) async {
    if (state is ApiProfileLoaded) {
      final currentState = state as ApiProfileLoaded;
      try {
        final userUuid = currentState.userData['uuid'];
        final newUserData = await _apiService.uploadProfilePicture(userUuid, event.imageFile);
        emit(currentState.copyWith(
          userData: newUserData,
          isUploadingImage: false,
          clearLocalPreviewFile: true,
        ));
        emit(const ApiProfileUpdateSuccess('Immagine del profilo aggiornata.'));
      } catch (e) {
        emit(ApiProfileError('Errore durante il caricamento: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    }
  }

  Future<void> _onProfileImageDeleteRequested(
      ApiProfileImageDeleteRequested event, Emitter<ApiProfileState> emit) async {
    if (state is ApiProfileLoaded) {
      final currentState = state as ApiProfileLoaded;
      emit(currentState.copyWith(isUploadingImage: true));
      try {
        final userUuid = currentState.userData['uuid'];
        final newUserData = await _apiService.deleteProfilePicture(userUuid);
        emit(currentState.copyWith(
          userData: newUserData,
          isUploadingImage: false,
        ));
        emit(const ApiProfileUpdateSuccess('Immagine del profilo eliminata.'));
      } catch (e) {
        emit(ApiProfileError('Errore durante l\'eliminazione: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
