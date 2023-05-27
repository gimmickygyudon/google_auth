import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserLog {
  final int id_olog;
  final DateTime date_time;
  final String from_sender, remarks, source;

  const UserLog({
    required this.id_olog,
    required this.date_time,
    required this.from_sender,
    required this.remarks,
    required this.source,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id_olog': id_olog,
      'date_time': date_time,
      'from_sender': from_sender,
      'remarks': remarks,
      'source': source,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'UserLog{id_olog: $id_olog, date_time: $date_time, from_sender: $from_sender, remarks: $remarks, source: $source}';
  }

  static Future<Database> initializeDatabase() async {
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'olog.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE olog(id_olog INTEGER PRIMARY KEY AUTOINCREMENT, date_time DATETIME, from_sender TEXT, remarks TEXT, source TEXT)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    return database;
  }

  // Define a function that inserts dogs into the database
  static Future<void> insert(UserLog user) async {
    // Get a reference to the database.
    final db = await UserLog.initializeDatabase();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'olog',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<UserLog>> retrieve([int? id_olog]) async {
    // Get a reference to the database.
    final db = await UserLog.initializeDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('olog');

    if (id_olog != null) {
      List<UserLog> user = maps.where((element) => element['id_olog'] == id_olog).map((e) {
        return UserLog(
          id_olog: e['id_olog'], 
          date_time: e['date_time'], 
          from_sender: e['from_sender'], 
          remarks: e['remarks'], 
          source: e['source']
        );
      }).toList();
      return user;
    } else {
      // Convert the List<Map<String, dynamic> into a List<Dog>.
      return List.generate(maps.length, (i) {
        return UserLog(
          id_olog: maps[i]['id_olog'],
          date_time: maps[i]['date_time'],
          from_sender: maps[i]['from_sender'],
          remarks: maps[i]['remarks'],
          source: maps[i]['source']
        );
      });
    }

    // Now, use the method above to retrieve all the dogs.
    // print(await retrieve()); // Prints a list that include Fido.
  }

  static Future<void> update(UserLog user) async {
    // Get a reference to the database.
    final db = await UserLog.initializeDatabase();

    // Update the given Dog.
    await db.update(
      'olog',
      user.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id_olog = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [user.id_olog],
    );
  }

  static Future<void> delete(int id_olog) async {
    // Get a reference to the database.
    final db = await UserLog.initializeDatabase();

    // Remove the Dog from the database.
    await db.delete(
      'olog',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id_olog],
    );
  }
}