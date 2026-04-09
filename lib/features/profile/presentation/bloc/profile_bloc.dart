import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../../core/error/failures.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileEntity profile;
  const ProfileUpdateRequested({required this.profile});
  @override
  List<Object?> get props => [profile];
}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  const ProfileLoaded({required this.profile});
  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(
      ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final profile = await getProfileUseCase(event.userId);
      emit(ProfileLoaded(profile: profile));
    } on Failure catch (e) {
      emit(ProfileError(message: e.message));
    }
  }

  Future<void> _onUpdate(
      ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      await updateProfileUseCase(event.profile);
      emit(const ProfileUpdated());
      emit(ProfileLoaded(profile: event.profile));
    } on Failure catch (e) {
      emit(ProfileError(message: e.message));
    }
  }
}
