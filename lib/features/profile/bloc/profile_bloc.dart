import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final ImagePicker _imagePicker;

  ProfileBloc({
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
    required ImagePicker imagePicker,
  })  : _firebaseAuth = firebaseAuth,
        _firebaseStorage = firebaseStorage,
        _imagePicker = imagePicker,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ProfileImagePickRequested>(_onProfileImagePickRequested);
    on<ProfileImageUploadRequested>(_onProfileImageUploadRequested);
    on<ProfileImageDeleteRequested>(_onProfileImageDeleteRequested);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(ProfileLoaded(
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isUploadingImage: false, // Ensure false on initial load
          localPreviewFile: null, // Ensure no preview on initial load
        ));
      } else {
        emit(const ProfileError('Utente non trovato.'));
      }
    } catch (e) {
      emit(ProfileError('Errore durante il caricamento del profilo: ${e.toString()}'));
    }
  }

  Future<void> _onProfileImagePickRequested(
      ProfileImagePickRequested event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isUploadingImage: true, clearLocalPreviewFile: true)); // Start loading, clear old preview
      try {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: event.source,
          imageQuality: 70,
          maxWidth: 800,
        );
        if (pickedFile != null) {
          // Emit state with local preview file, isUploadingImage remains true
          emit(currentState.copyWith(
            localPreviewFile: File(pickedFile.path),
            isUploadingImage: true, // Explicitly ensure it's true
          ));
          add(ProfileImageUploadRequested(File(pickedFile.path)));
        } else {
          // User cancelled picker
          emit(currentState.copyWith(isUploadingImage: false, clearLocalPreviewFile: true));
        }
      } catch (e) {
        emit(ProfileError('Errore durante la selezione dell\'immagine: ${e.toString()}'));
        // Ensure isUploadingImage is reset and preview cleared on error during picking
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

    // Assuming state is ProfileLoaded with isUploadingImage: true and localPreviewFile set.
    try {
      final filePath = 'profile_pictures/${user.uid}/profile.jpg';
      final ref = _firebaseStorage.ref().child(filePath);
      await ref.putFile(event.imageFile);
      final downloadUrl = await ref.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);

      emit(ProfileLoaded(
        displayName: user.displayName,
        email: user.email,
        photoUrl: downloadUrl,
        isUploadingImage: false,     // Uploading finished
        localPreviewFile: null,      // Clear preview on successful upload
      ));
      emit(const ProfileUpdateSuccess('Immagine del profilo aggiornata.'));
    } on FirebaseException catch (e) {
      emit(ProfileError('Errore Firebase durante il caricamento: ${e.message}'));
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(isUploadingImage: false)); // Don't clear preview on upload error, user might want to retry
      }
    } catch (e) {
      emit(ProfileError('Errore sconosciuto durante il caricamento: ${e.toString()}'));
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(isUploadingImage: false));
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
      emit(currentState.copyWith(isUploadingImage: true, clearLocalPreviewFile: true)); // Start loading, clear preview
    } else {
      emit(const ProfileError('Profilo non caricato. Impossibile eliminare l\'immagine.'));
      return;
    }

    try {
      if (user.photoURL != null) {
        try {
          final String filePath = 'profile_pictures/${user.uid}/profile.jpg';
          final ref = _firebaseStorage.ref().child(filePath);
          await ref.delete();
        } on FirebaseException catch (storageError) {
          print('Avviso: Errore durante l\'eliminazione dell\'immagine da Storage: ${storageError.message}');
        }
      }
      await user.updatePhotoURL(null);

      emit(ProfileLoaded(
        displayName: user.displayName,
        email: user.email,
        photoUrl: null,
        isUploadingImage: false,     // Deletion finished
        localPreviewFile: null,      // Ensure preview is cleared
      ));
      emit(const ProfileUpdateSuccess('Immagine del profilo eliminata.'));
    } on FirebaseException catch (e) {
      emit(ProfileError('Errore Firebase durante l\'eliminazione: ${e.message}'));
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(isUploadingImage: false));
      }
    } catch (e) {
      emit(ProfileError('Errore sconosciuto durante l\'eliminazione: ${e.toString()}'));
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(isUploadingImage: false));
      }
    }
  }
}
