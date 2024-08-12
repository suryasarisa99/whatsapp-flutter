import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'msgstore.db');
    return await openDatabase(
      path,
    );
  }
  // Future<Database> _initDatabase() async {
  //   String path = join(await getDatabasesPath(), 'msgstore.db');
  //   Database db = await openDatabase(
  //     path,
  //     readOnly: false,
  //   );

  //   // Disable WAL mode
  //   await db.rawQuery('PRAGMA journal_mode=DELETE');

  //   // Check database integrity
  //   var result = await db.rawQuery('PRAGMA integrity_check');
  //   if (result[0]['integrity_check'] != 'ok') {
  //     throw Exception('Database integrity check failed');
  //   }

  //   return db;
  // }

  void test1() async {
    final db = await database;
    final result = await db.query('audio_data');
    print(result);
  }

  void test2() async {
    final db = await database;
    final result = await db.query('wa_address_book');
    print(result);
  }

  Future<List<DbChat>> getChatList() async {
    final db = await database;

    const query = ''' SELECT
          message.chat_row_id as id,
          count(*) as count,
          jid.user as no,
          chat.subject as group_name,
          last_message.text_data as mssg,
          last_message.timestamp as date
      FROM
          message
      JOIN
          chat ON chat._id = message.chat_row_id
      JOIN
          jid ON chat.jid_row_id = jid._id
      JOIN
          message as last_message ON chat.last_message_row_id = last_message._id
      WHERE
          message.text_data IS NOT NULL
      GROUP BY
          message.chat_row_id
      HAVING
          count(message.chat_row_id) > 0
      ORDER BY
          date DESC
      LIMIT 100;''';
    List<Map<String, dynamic>> result = await db.rawQuery(query, []);

    print(result);

    return result.map((e) => DbChat.fromMap(e)).toList();
  }
}
