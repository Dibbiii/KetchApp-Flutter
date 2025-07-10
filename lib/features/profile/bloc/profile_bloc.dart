import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final ImagePicker _imagePicker;
  final ApiService _apiService;
  final AuthBloc _authBloc;

  ProfileBloc({
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
    required ImagePicker imagePicker,
    required ApiService apiService,
    required AuthBloc authBloc,
  })  : _apiService = apiService,
        _authBloc = authBloc,
        _firebaseAuth = firebaseAuth,
        _firebaseStorage = firebaseStorage,
        _imagePicker = imagePicker,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ProfileImagePickRequested>(_onProfileImagePickRequested);
    on<ProfileImageUploadRequested>(_onProfileImageUploadRequested);
    on<ProfileImageDeleteRequested>(_onProfileImageDeleteRequested);
    on<LoadAchievements>(_onLoadAchievements);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    final user = _firebaseAuth.currentUser;
    String? username;
    if (user != null) {
      String? userUuid;
      final authState = _authBloc.state;
      if (authState is Authenticated) {
        userUuid = authState.userUuid;
      }
      if (userUuid != null) {
        try {
          final userData = await _apiService.fetchData('users/$userUuid');
          username = userData['username'] as String?;
        } catch (e) {
        }
      }
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          username: username,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isUploadingImage: false,
          clearLocalPreviewFile: true,
        ));
      } else {
        emit(ProfileLoaded(
          username: username,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isUploadingImage: false,
          localPreviewFile: null,
        ));
      }

      add(LoadAchievements());
    } else {
      emit(const ProfileError('Utente non trovato.'));
    }
  }

  Future<void> _onProfileImagePickRequested(
      ProfileImagePickRequested event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isUploadingImage: true, clearLocalPreviewFile: true));
      try {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: event.source,
          imageQuality: 70,
          maxWidth: 800,
        );
        if (pickedFile != null) {
          emit(currentState.copyWith(
            localPreviewFile: File(pickedFile.path),
            isUploadingImage: true,
          ));
          add(ProfileImageUploadRequested(File(pickedFile.path)));
        } else {
          emit(currentState.copyWith(isUploadingImage: false, clearLocalPreviewFile: true));
        }
      } catch (e) {
        emit(ProfileError('Errore durante la selezione dell\'immagine: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false, clearLocalPreviewFile: true));
      }
    } else {
      emit(const ProfileError('Profilo non caricato. Impossibile selezionare l\'immagine.'));
    }
  }

  Future<void> _onProfileImageUploadRequested(
      ProfileImageUploadRequested event, Emitter<ProfileState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(const ProfileError('Utente non autenticato per caricare l\'immagine.'));
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(isUploadingImage: false, clearLocalPreviewFile: true));
      }
      return;
    }
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        final filePath = 'profile_pictures/${user.uid}/profile.jpg';
        final ref = _firebaseStorage.ref().child(filePath);
        await ref.putFile(event.imageFile);
        final downloadUrl = await ref.getDownloadURL();
        await user.updatePhotoURL(downloadUrl);
        emit(currentState.copyWith(
          photoUrl: downloadUrl,
          isUploadingImage: false,
          clearLocalPreviewFile: true,
        ));
        emit(const ProfileUpdateSuccess('Immagine del profilo aggiornata.'));
        add(LoadProfile());
      } on FirebaseException catch (e) {
        emit(ProfileError('Errore Firebase durante il caricamento: ${e.message}'));
        emit(currentState.copyWith(isUploadingImage: false));
      } catch (e) {
        emit(ProfileError('Errore sconosciuto durante il caricamento: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    }
  }

  Future<void> _onProfileImageDeleteRequested(
      ProfileImageDeleteRequested event, Emitter<ProfileState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(const ProfileError('Utente non autenticato per eliminare l\'immagine.'));
      return;
    }
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isUploadingImage: true, clearLocalPreviewFile: true));
      try {
        if (user.photoURL != null) {
          try {
            final String filePath = 'profile_pictures/${user.uid}/profile.jpg';
            final ref = _firebaseStorage.ref().child(filePath);
            await ref.delete();
          } on FirebaseException {
          }
        }
        await user.updatePhotoURL(null);
        emit(currentState.copyWith(
          photoUrl: null,
          isUploadingImage: false,
          clearLocalPreviewFile: true,
        ));
        emit(const ProfileUpdateSuccess('Immagine del profilo eliminata.'));
        add(LoadProfile());
      } on FirebaseException catch (e) {
        emit(ProfileError('Errore Firebase durante l\'eliminazione: ${e.message}'));
        emit(currentState.copyWith(isUploadingImage: false));
      } catch (e) {
        emit(ProfileError('Errore sconosciuto durante l\'eliminazione: ${e.toString()}'));
        emit(currentState.copyWith(isUploadingImage: false));
      }
    } else {
      emit(const ProfileError('Profilo non caricato. Impossibile eliminare l\'immagine.'));
    }
  }

  Future<void> _onLoadAchievements(
      LoadAchievements event, Emitter<ProfileState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          achievementsLoading: false,
          achievementsError: 'Utente non autenticato.',
        ));
      }
      return;
    }
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(
        achievementsLoading: true,
        achievementsError: null,
      ));
    }
    try {
      String? userUuid;
      final authState = _authBloc.state;
      if (authState is Authenticated) {
        userUuid = authState.userUuid;
      }
      if (userUuid != null) {
        final all = await _apiService.getAllAchievements();
        final completed = await _apiService.getUserAchievements(userUuid);
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(
            allAchievements: all,
            completedAchievementTitles: completed.map((a) => a.title).toSet(),
            achievementsLoading: false,
            achievementsError: null,
          ));
        }
      } else {
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(
            achievementsLoading: false,
            achievementsError: 'Utente non autenticato.',
          ));
        }
      }
    } catch (e) {
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          achievementsLoading: false,
          achievementsError: 'Errore nel caricamento achievements: ${e.toString()}',
        ));
      }
    }
  }
}
