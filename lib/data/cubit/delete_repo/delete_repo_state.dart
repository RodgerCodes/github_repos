part of 'delete_repo_cubit.dart';

@immutable
sealed class DeleteRepoState {}

final class DeleteRepoInitial extends DeleteRepoState {}

final class DeletingRepoData extends DeleteRepoState {}

final class DeleteingRepoDataSuccess extends DeleteRepoState {
  final String message;

  DeleteingRepoDataSuccess({required this.message});
}

final class DeletingRepoDataError extends DeleteRepoState {
  final String message;

  DeletingRepoDataError({required this.message});
}
