import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ImagePicker _imagePicker;
  final ApiService _apiService;
  final AuthBloc _authBloc;

  ProfileBloc({
    required ImagePicker imagePicker,
    required ApiService apiService,
    required AuthBloc authBloc,
  }) : _apiService = apiService,
       _authBloc = authBloc,
       _imagePicker = imagePicker,
       super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ProfileImagePickRequested>(_onProfileImagePickRequested);
    on<ProfileImageUploadRequested>(_onProfileImageUploadRequested);
    on<ProfileImageDeleteRequested>(_onProfileImageDeleteRequested);
    on<LoadAchievements>(_onLoadAchievements);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final authState = _authBloc.state;
    if (authState is AuthAuthenticated) {
      try {
        final userData = await _apiService.fetchData('users/@me');
        emit(
          ProfileLoaded(
            username: userData['username'] as String?,
            email: userData['email'] as String?,
          ),
        );
        add(LoadAchievements());
        print('User: ${userData}');
      } catch (e) {
        emit(ProfileError('Errore nel caricamento profilo: ${e.toString()}'));
      }
    } else {
      emit(const ProfileError('Utente non autenticato.'));
    }
  }

  Future<void> _onProfileImagePickRequested(
    ProfileImagePickRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
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
          emit(
            currentState.copyWith(
              localPreviewFile: File(pickedFile.path),
              isUploadingImage: true,
            ),
          );
          add(ProfileImageUploadRequested(File(pickedFile.path)));
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
          ProfileError(
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
    } else {
      emit(
        const ProfileError(
          'Profilo non caricato. Impossibile selezionare l\'immagine.',
        ),
      );
    }
  }

  Future<void> _onProfileImageUploadRequested(
    ProfileImageUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(
        const ProfileError('Utente non autenticato per caricare l\'immagine.'),
      );
      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            isUploadingImage: false,
            clearLocalPreviewFile: true,
          ),
        );
      }
      return;
    }
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        // Chiamata API custom per upload immagine profilo
        final response = await _apiService.postData(
          'users/${authState.id}/profile-picture',
          {'filePath': event.imageFile.path},
        );
        emit(
          currentState.copyWith(
            photoUrl: response['photoUrl'],
            isUploadingImage: false,
            clearLocalPreviewFile: true,
          ),
        );
        emit(const ProfileUpdateSuccess('Immagine del profilo aggiornata.'));
        add(LoadProfile());
      } catch (e) {
        emit(ProfileError('Errore durante il caricamento: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    }
  }

  Future<void> _onProfileImageDeleteRequested(
    ProfileImageDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(
        const ProfileError('Utente non autenticato per eliminare l\'immagine.'),
      );
      return;
    }
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(
        currentState.copyWith(
          isUploadingImage: true,
          clearLocalPreviewFile: true,
        ),
      );
      try {
        // Chiamata API custom per eliminare immagine profilo
        await _apiService.deleteData('users/${authState.id}/profile-picture');
        emit(
          currentState.copyWith(
            photoUrl: null,
            isUploadingImage: false,
            clearLocalPreviewFile: true,
          ),
        );
        emit(const ProfileUpdateSuccess('Immagine del profilo eliminata.'));
        add(LoadProfile());
      } catch (e) {
        emit(ProfileError('Errore durante l\'eliminazione: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    } else {
      emit(
        const ProfileError(
          'Profilo non caricato. Impossibile eliminare l\'immagine.',
        ),
      );
    }
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProfileState> emit,
  ) async {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) {
      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            achievementsLoading: false,
            achievementsError: 'Utente non autenticato.',
          ),
        );
      }
      return;
    }
    if (state is ProfileLoaded) {
      emit(
        (state as ProfileLoaded).copyWith(
          achievementsLoading: true,
          achievementsError: null,
        ),
      );
    }
    try {
      final completed = await _apiService.getUserAchievements();
      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            completedAchievementTitles: completed.map((a) => a.title).toSet(),
            achievementsLoading: false,
            achievementsError: null,
          ),
        );
      }
    } catch (e) {
      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            achievementsLoading: false,
            achievementsError:
                'Errore nel caricamento achievements: ${e.toString()}',
          ),
        );
      }
    }
  }
}
