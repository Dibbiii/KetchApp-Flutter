import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ApiProfileEvent {}

class LoadApiProfile extends ApiProfileEvent {}

class ApiProfileImagePickRequested extends ApiProfileEvent {
  final ImageSource source;
  ApiProfileImagePickRequested(this.source);
}

class ApiProfileImageUploadRequested extends ApiProfileEvent {
  final File imageFile;
  ApiProfileImageUploadRequested(this.imageFile);
}

class ApiProfileImageDeleteRequested extends ApiProfileEvent {}

