import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repos/data/api/repos_api.dart';
import 'package:github_repos/data/cubit/delete_repo/delete_repo_cubit.dart';
import 'package:github_repos/data/cubit/repo/repo_cubit.dart';
import 'package:github_repos/utils/helpers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Repos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RepoCubit(
              repoManager: RepoManager(),
            ),
          ),
          BlocProvider(
            create: (context) => DeleteRepoCubit(repoManager: RepoManager()),
          ),
        ],
        child: const MyHomePage(title: 'Github Repos'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic clickedID;
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<RepoCubit>(context).fetchAndStoreData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: BlocBuilder<RepoCubit, RepoState>(
        builder: (context, state) {
          if (state is FetchingReposSuccess) {
            return ListView.builder(
              itemCount: state.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    child: CachedNetworkImage(
                      imageUrl: state.data[index].avataUrl,
                    ),
                  ),
                  title: Text(
                    state.data[index].fullname,
                  ),
                  subtitle: Text(
                    state.data[index].description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: BlocConsumer<DeleteRepoCubit, DeleteRepoState>(
                    listener: (context2, state2) {
                      if (state2 is DeleteingRepoDataSuccess) {
                        // display message on successfull operation
                        toast(context, state2.message);

                        // refetch data from the database to update the ui
                        BlocProvider.of<RepoCubit>(context).fetchAndStoreData();
                      }
                    },
                    builder: (context2, state2) {
                      // check the current state of the operation
                      if (state2 is DeletingRepoData) {
                        //  check if the clicked id = the current index of repo
                        if (clickedID == state.data[index].id) {
                          // display circular progress loader on the item being deleted
                          return const CircularProgressIndicator(
                            color: Colors.green,
                          );
                        } else {
                          // return a regular delete icon
                          return const Icon(
                            Icons.delete,
                          );
                        }
                      } else {
                        return GestureDetector(
                          onTap: () {
                            // set the clicked item id to the clicked item
                            setState(() {
                              clickedID = state.data[index].id;
                            });

                            // call database operation on the item
                            BlocProvider.of<DeleteRepoCubit>(context)
                                .deleteItem(clickedID);
                          },
                          child: const Icon(
                            Icons.delete,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          } else if (state is FetchingReposError) {
            // display error message if there is error when fetching data from database
            return Center(
              child: Text(
                state.message,
              ),
            );
          } else {
            // progress indicator when fetching data
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}
