import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

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


class ProfileImageDeleteRequested extends ProfileEvent {}


class LoadAchievements extends ProfileEvent {}

