import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:ketchapp_flutter/models/achievement.dart';

abstract class ApiProfileState extends Equatable {
  const ApiProfileState();

  @override
  List<Object?> get props => [];
}

class ApiProfileInitial extends ApiProfileState {}

class ApiProfileLoading extends ApiProfileState {}

class ApiProfileLoaded extends ApiProfileState {
  final Map<String, dynamic> userData;
  final File? localPreviewFile;
  final bool isUploadingImage;
  final List<dynamic>? allAchievements;
  final Set<String>? completedAchievementTitles;
  final bool achievementsLoading;
  final String? achievementsError;

  const ApiProfileLoaded({
    required this.userData,
    this.localPreviewFile,
    this.isUploadingImage = false,
    this.allAchievements,
    this.completedAchievementTitles,
    this.achievementsLoading = false,
    this.achievementsError,
  });

  ApiProfileLoaded copyWith({
    Map<String, dynamic>? userData,
    File? localPreviewFile,
    bool? isUploadingImage,
    bool clearLocalPreviewFile = false,
    List<dynamic>? allAchievements,
    Set<String>? completedAchievementTitles,
    bool? achievementsLoading,
    String? achievementsError,
  }) {
    return ApiProfileLoaded(
      userData: userData ?? this.userData,
      localPreviewFile: clearLocalPreviewFile ? null : localPreviewFile ?? this.localPreviewFile,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      allAchievements: allAchievements ?? this.allAchievements,
      completedAchievementTitles: completedAchievementTitles ?? this.completedAchievementTitles,
      achievementsLoading: achievementsLoading ?? this.achievementsLoading,
      achievementsError: achievementsError ?? this.achievementsError,
    );
  }

  @override
  List<Object?> get props => [
        userData,
        localPreviewFile,
        isUploadingImage,
        allAchievements,
        completedAchievementTitles,
        achievementsLoading,
        achievementsError,
      ];
}

class ApiProfileError extends ApiProfileState {
  final String message;

  const ApiProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class ApiProfileUpdateSuccess extends ApiProfileState {
    final String message;

  const ApiProfileUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

