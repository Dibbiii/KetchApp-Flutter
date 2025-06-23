import 'dart:io'; // Necessario per File
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart'; // Necessario per ImageSource

abstract class ProfileEvent extends Equatable {
  const ProfileEvent(); // Aggiunto const constructor

  @override
  List<Object?> get props => [];
}

// Per caricare i dati iniziali del profilo
class LoadProfile extends ProfileEvent {}

// Per richiedere la selezione di una nuova immagine del profilo
class ProfileImagePickRequested extends ProfileEvent {
  final ImageSource source;

  const ProfileImagePickRequested(this.source);

  @override
  List<Object?> get props => [source];
}

class ProfileImageUploadRequested extends ProfileEvent {
  final File imageFile;

  const ProfileImageUploadRequested(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

// Per eliminare l'immagine del profilo corrente
class ProfileImageDeleteRequested extends ProfileEvent {}

// Per caricare achievements
class LoadAchievements extends ProfileEvent {}

