import 'package:bloc/bloc.dart';
import 'package:github_repos/data/api/repos_api.dart';
import 'package:meta/meta.dart';

part 'delete_repo_state.dart';

class DeleteRepoCubit extends Cubit<DeleteRepoState> {
  final RepoManager repoManager;
  DeleteRepoCubit({required this.repoManager}) : super(DeleteRepoInitial());

  void deleteItem(dynamic id) {
    emit(DeletingRepoData());
    repoManager.deleteItem(id).then((value) {
      emit(DeleteingRepoDataSuccess(message: value['msg']));
    });
  }
}
