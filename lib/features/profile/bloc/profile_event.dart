import 'dart:io'; // Necessario per File
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart'; // Necessario per ImageSource

abstract class ProfileEvent extends Equatable {
  const ProfileEvent(); // Aggiunto const constructor

  @override
  List<Object?> get props => [];
}

// Evento per caricare i dati iniziali del profilo
class LoadProfile extends ProfileEvent {}

// Evento per richiedere la selezione di una nuova immagine del profilo
class ProfileImagePickRequested extends ProfileEvent {
  final ImageSource source;

  const ProfileImagePickRequested(this.source);

  @override
  List<Object?> get props => [source];
}

// Evento per caricare l'immagine del profilo selezionata
// Potrebbe essere omesso se ProfileImagePickRequested gestisce direttamente il caricamento
// Ma separarlo può dare più controllo sullo stato (es. mostrare l'immagine prima di caricarla)
class ProfileImageUploadRequested extends ProfileEvent {
  final File imageFile;

  const ProfileImageUploadRequested(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

// Evento per eliminare l'immagine del profilo corrente
class ProfileImageDeleteRequested extends ProfileEvent {}

// Potresti aggiungere altri eventi se permetti la modifica di altri campi del profilo
// Esempio:
// class UpdateDisplayNameRequested extends ProfileEvent {
//   final String newDisplayName;
//   const UpdateDisplayNameRequested(this.newDisplayName);
//   @override
//   List<Object?> get props => [newDisplayName];
// }
