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
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Se già ProfileLoaded, aggiorna solo i dati, altrimenti emetti ProfileLoaded
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isUploadingImage: false,
          clearLocalPreviewFile: true,
        ));
      } else {
        emit(ProfileLoaded(
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isUploadingImage: false,
          localPreviewFile: null,
        ));
      }
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
        // Dopo il successo, ricarica il profilo per tornare a ProfileLoaded
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
          } on FirebaseException catch (storageError) {
            print('Avviso: Errore durante l\'eliminazione dell\'immagine da Storage: ${storageError.message}');
          }
        }
        await user.updatePhotoURL(null);
        emit(currentState.copyWith(
          photoUrl: null,
          isUploadingImage: false,
          clearLocalPreviewFile: true,
        ));
        emit(const ProfileUpdateSuccess('Immagine del profilo eliminata.'));
        // Dopo il successo, ricarica il profilo per tornare a ProfileLoaded
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
}
