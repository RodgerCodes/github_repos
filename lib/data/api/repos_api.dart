import 'dart:io';
import 'package:github_repos/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RepoManager {
  late Database _database;

  // This method initializes the sqlite database whenever called in the codebase
  Future openDB() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), "repos.db"),
      version: 3,

      // runs the sql command to initiate a table in the database
      onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE IF NOT EXISTS repo(id INTEGER PRIMARY KEY autoincrement, fullname TEXT, login TEXT, avataUrl TEXT, type TEXT, description TEXT, private TEXT)");
      },
    );
    return _database;
  }

//  This method fetches github repos and save them
  Future fetchAndSaveRepos() async {
    try {
      // create the db
      await openDB();

      var dbData = await fetchData();

      // Check if the local database has data available
      // this is done to avoid making api calls every time the screen is refreshed
      if (dbData.length == 0) {
        // make http request

        final request = await http.get(Uri.parse(baseUrl));

        // unmarshal json data
        final response = convert.jsonDecode(request.body);

        if (request.statusCode == 200 || request.statusCode == 304) {
          // loop through the response

          for (int index = 0; index < response.length; index++) {
            // save data in the sql database
            await _database.insert("repo", {
              "fullname": response[index]['full_name'],
              "login": response[index]['owner']['login'],
              "avataUrl": response[index]['owner']['avatar_url'],
              "type": response[index]['owner']['type'],
              "description": response[index]['description'],
              "private": response[index]['private']
                  .toString(), //Converting the boolean value to a string as sqlite has not native support for boolean field
            });
          }

          //  get data saved in local database
          dbData = await fetchData();

          return {
            'error': false,
            'data': dbData, // an indicator showing data has been saved,
          };
        } else {
          return {
            'error': true,
            'msg': 'Something went wrong when fetching repository data'
          };
        }

        // the else statement just returns data in the local database
      } else {
        return {
          'error': false,
          'data': dbData,
        };
      }
    } on HttpException {
      return {
        'error': true,
        'msg': 'Oops! Something is wrong on our end',
      };
    } on SocketException {
      return {
        'error': true,
        'msg':
            'Cannot connect to an api service, check your internet connection',
      };
    }
  }

//  Fetch data from the sqlite database returns a list of the data
  Future fetchData() async {
    await openDB();
    final List repos = await _database.query("repo");
    return repos;
  }

// delete item from the sqlite database returns an object with a msg param
  Future deleteItem(dynamic id) async {
    await openDB();

    await _database.delete("repo", where: "id = ?", whereArgs: [id]);

    return {
      'msg': 'Item deleted',
    };
  }
}
