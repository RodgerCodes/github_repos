import 'package:bloc/bloc.dart';
import 'package:github_repos/data/api/repos_api.dart';
import 'package:github_repos/data/models/repo.dart';
import 'package:meta/meta.dart';

part 'repo_state.dart';

class RepoCubit extends Cubit<RepoState> {
  final RepoManager repoManager;
  RepoCubit({required this.repoManager}) : super(RepoInitial());

  void fetchAndStoreData() {
    repoManager.fetchAndSaveRepos().then((value) {
      if (value['error']) {
        emit(FetchingReposError(message: value['msg']));
      } else {
        dynamic repos =
            value['data'].map((json) => Repo.fromJson(json)).toList();
        emit(FetchingReposSuccess(data: repos));
      }
    });
  }
}
