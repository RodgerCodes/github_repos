part of 'repo_cubit.dart';

@immutable
sealed class RepoState {}

final class RepoInitial extends RepoState {}

final class FetchingRepos extends RepoState {}

final class FetchingReposError extends RepoState {
  final String message;

  FetchingReposError({required this.message});
}

final class FetchingReposSuccess extends RepoState {
  final List data;

  FetchingReposSuccess({required this.data});
}
