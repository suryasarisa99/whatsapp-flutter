import 'package:flutter/material.dart';
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

  Future<void> disonnect() async {
    _database?.close();
    _database = null;
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

    const query = '''
  SELECT
      chat_view._id as cid,  
      raw_string_jid as raw_jid,  
      jid.user as no,
      chat_view.subject as group_name,
      unseen_message_count as umc,
      SUBSTR(last_message.text_data, 1, 30) as mssg,
      last_message.message_type as mssg_type,
      last_message.timestamp as date,
      participation_status as ps,
      archived
  FROM
      chat_view
  JOIN
      jid ON chat_view.raw_string_jid = jid.raw_string
  JOIN
      message as last_message ON chat_view.last_message_row_id = last_message._id
  WHERE 
      chat_view.archived >= 0
  ORDER BY
      last_message.timestamp DESC''';

    List<Map<String, dynamic>> result = await db.rawQuery(query, []);

    print(result);

    return result.map((e) => DbChat.fromMap(e)).toList();
  }

  Future<List<DbMssg>> getMessages(int cid) async {
    final query = """SELECT 
    message._id as mid,
    message.key_id as kid,
    message.from_me as me, 
    message.text_data as text, 
    message.message_type as type,
    message.timestamp as date,
    message_media.file_path as file,
    message_media.media_name as name,
    message_media.file_size as size,
    message_media.file_length as length,
    message_media.width as width,
    message_media.height as height,
    message_media.media_duration as duration,
    message_media.page_count as count,
    message_quoted.key_id as quoted_kid,
    GROUP_CONCAT(message_poll_option.option_name || '<<:>>' || message_poll_option.vote_total, '<<|>>') as options
    FROM message
    LEFT JOIN 
        message_media ON message._id = message_media.message_row_id
    LEFT JOIN
        message_poll_option On message._id = message_poll_option.message_row_id
    LEFT JOIN
        message_quoted on message_quoted.message_row_id = message._id
    WHERE message.chat_row_id = $cid And type != 7
    Group By message._id
    Order By message.timestamp DESC;
    """;
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(query, []);
    // debugPrint(result.toString());
    return result.map((e) => DbMssg.fromMap(e)).toList();
  }
  // Future<List<DbMssg>> getMessages(int cid) async {
  //   final query = """SELECT
  //     message._id as mid,
  //     message.from_me as me,
  //     message.text_data as text,
  //     message.message_type as type,
  //     message_media.file_path as file,
  //     message.timestamp as date
  //   FROM message
  //   LEFT JOIN
  //       message_media ON message._id = message_media.message_row_id
  //   WHERE message.chat_row_id = $cid And type != 7
  //   Group By message._id
  //   Order By message.timestamp DESC;
  //   """;
  //   final db = await database;
  //   List<Map<String, dynamic>> result = await db.rawQuery(query, []);
  //   // debugPrint(result.toString());
  //   return result.map((e) => DbMssg.fromMap(e)).toList();
  // }

  Future<List<Map<String, int>>> getMediaCount(int cid) async {
    final query = """SELECT 
      message.message_type as type, 
      count(*) as count
    FROM message
    LEFT JOIN 
        message_media ON message._id = message_media.message_row_id
    WHERE message.chat_row_id = $cid And type != 7
    Group By message.message_type
    Order By count DESC;
    """;
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(query, []);
    final List<Map<String, int>> intResult = result.map((e) {
      return {
        'type': e['type'] as int,
        'count': e['count'] as int,
      };
    }).toList();
    return intResult;
  }

  Future<List<DbMssg>> getMssgsOfType(int cid, int type) async {
    final query = """SELECT 
    message._id as mid,
    message.key_id as kid,
    message.from_me as me, 
    message.text_data as text, 
    message.message_type as type,
    message.timestamp as date,
    message_media.file_path as file,
    message_media.media_name as name,
    message_media.file_size as size,
    message_media.file_length as length,
    message_media.width as width,
    message_media.height as height,
    message_media.media_duration as duration,
    message_media.page_count as count,
    message_quoted.key_id as quoted_kid,
    GROUP_CONCAT(message_poll_option.option_name || '<<:>>' || message_poll_option.vote_total, '<<|>>') as options
    FROM message
    LEFT JOIN 
        message_media ON message._id = message_media.message_row_id
    LEFT JOIN
        message_poll_option On message._id = message_poll_option.message_row_id
    LEFT JOIN
        message_quoted on message_quoted.message_row_id = message._id
    WHERE message.chat_row_id = $cid And type = $type
    Group By message._id
    Order By message.timestamp DESC;
    """;
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(query, []);
    // debugPrint(result.toString());
    return result.map((e) => DbMssg.fromMap(e)).toList();
  }
}
