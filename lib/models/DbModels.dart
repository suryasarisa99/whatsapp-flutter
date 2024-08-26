class DbChat {
  final int cid;
  final String no;
  final String? groupName;
  final String? mssg;
  // message type:
  // 0. text messg
  // 1. image mssg
  // 2  - audio
  // 3  - video
  // 4  - contact
  // 7  - whatsapp info mssgs
  // 9  - file document
  // 13 - some kind of video
  // 15 - deleted mssg
  // 20 - sticker
  // 64 - deleted by admin
  // 66 - poll
  // 90 - call
  final int mssgType;
  final int? date;
  final int archived;
  final String rawJid;
  // participant status:
  // 0 or null- not group ( individual chat )
  // 1 - community chat may be
  // 2 - group chat member
  // 3 - group chat admin
  // 4 - group chat owner (creator)
  final int? ps;
  // unread message count
  final int umc;

  DbChat({
    required this.cid,
    required this.no,
    this.groupName,
    this.mssg,
    this.date,
    required this.mssgType,
    required this.archived,
    required this.ps,
    required this.umc,
    required this.rawJid,
  });

  factory DbChat.fromMap(Map<String, dynamic> map) {
    return DbChat(
      rawJid: map['raw_jid'],
      cid: map['cid'],
      no: map['no'],
      groupName: map['group_name'],
      mssg: map['mssg'],
      mssgType: map['mssg_type'],
      date: map['date'],
      archived: map['archived'],
      ps: map['ps'],
      umc: map['umc'],
    );
  }

  DbChat copyWith({
    int? cid,
    String? no,
    String? groupName,
    String? mssg,
    int? mssgType,
    int? date,
    int? archived,
    int? ps,
  }) {
    return DbChat(
      cid: cid ?? this.cid,
      no: no ?? this.no,
      groupName: groupName ?? this.groupName,
      mssg: mssg ?? this.mssg,
      mssgType: mssgType ?? this.mssgType,
      date: date ?? this.date,
      archived: archived ?? this.archived,
      ps: ps ?? this.ps,
      umc: umc,
      rawJid: rawJid,
    );
  }
}

// class DbMssg {
//   final int mid;
//   final int me;
//   final String? text;
//   final int timestamp;
//   final String? file;
//   final int type;

//   DbMssg({
//     required this.mid,
//     required this.me,
//     required this.text,
//     required this.timestamp,
//     required this.file,
//     required this.type,
//   });

//   factory DbMssg.fromMap(Map<String, dynamic> map) {
//     return DbMssg(
//       mid: map['mid'],
//       me: map['me'],
//       text: map['text'],
//       timestamp: map['date'],
//       file: map['file'],
//       type: map['type'],
//     );
//   }
// }

class DbMssgs {
  final List<DbMssg> mssgs;
  final DbChat chat;

  DbMssgs({required this.mssgs, required this.chat});
}

class DbMssg {
  final int mid;
  final String kid;
  final int me;
  final String? text;
  final int timestamp;
  final int type;
  final String? quoted_kid;

  DbMssg({
    required this.mid,
    required this.kid,
    required this.me,
    required this.text,
    required this.timestamp,
    required this.type,
    required this.quoted_kid,
  });

  factory DbMssg.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as int;
    switch (type) {
      case 0:
        return DbMssg(
          mid: map['mid'],
          kid: map['kid'],
          me: map['me'],
          text: map['text'],
          timestamp: map['date'],
          type: map['type'],
          quoted_kid: map['quoted_kid'],
        );
      case 1:
      case 20:
        return DbMssgImageFile.fromMap(map);
      case 2:
      case 3:
        return DbMssgVideoFile.fromMap(map);
      case 9:
        return DbMssgDocumentFile.fromMap(map);
      case 66:
        return DbMssgPoll.fromMap(map);
      default:
        return DbMssg(
          mid: map['mid'],
          kid: map['kid'],
          me: map['me'],
          text: map['text'],
          timestamp: map['date'],
          type: map['type'],
          quoted_kid: map['quoted_kid'],
        );
    }
  }
}

class DbMssgFile extends DbMssg {
  DbMssgFile({
    required super.mid,
    required super.me,
    required super.text,
    required super.timestamp,
    required super.kid,
    required super.quoted_kid,
    required super.type,
    required this.file,
    required this.name,
    required this.length,
    required this.size,
    required this.mime,
  });

  final int length;
  final int? size;
  final String? file;
  final String? name;
  final String? mime;
}

class PollOptions {
  final String option;
  final int count;

  const PollOptions({required this.option, required this.count});
}

class DbMssgPoll extends DbMssg {
  DbMssgPoll({
    required super.mid,
    required super.me,
    required super.text,
    required super.timestamp,
    required super.type,
    required super.kid,
    required super.quoted_kid,
    required this.pollOptions,
  });

  final List<PollOptions> pollOptions;

  factory DbMssgPoll.fromMap(Map<String, dynamic> map) {
    print("Before Done");
    print(map['options']);
    List<PollOptions> pollOptions = [];
    if (map['options'] is String) {
      pollOptions = (map['options'] as String).split('<<|>>').map((option) {
        final parts = option.split('<<:>>');
        print(parts);
        return PollOptions(option: parts[0], count: int.parse(parts[1]));
      }).toList();
    } else {
      throw Exception('Invalid options format');
    }
    print("Done");
    return DbMssgPoll(
      mid: map['mid'],
      me: map['me'],
      text: map['text'],
      timestamp: map['date'],
      type: map['type'],
      kid: map['kid'],
      quoted_kid: map['quoted_kid'],
      pollOptions: pollOptions,
    );
  }
}

class DbMssgImageFile extends DbMssgFile {
  DbMssgImageFile({
    required super.mid,
    required super.me,
    required super.text,
    required super.timestamp,
    required super.type,
    required super.kid,
    required super.quoted_kid,
    required super.file,
    required super.mime,
    required super.name,
    required super.length,
    required super.size,
    required this.height,
    required this.width,
  });

  final int? height;
  final int? width;

  factory DbMssgImageFile.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as int;
    return DbMssgImageFile(
      mid: map['mid'],
      me: map['me'],
      text: map['text'],
      timestamp: map['date'],
      type: map['type'],
      kid: map['kid'],
      quoted_kid: map['quoted_kid'],
      file: map['file'],
      mime: map['mime'],
      name: map['name'],
      length: map['length'],
      size: map['size'],
      height: map['height'],
      width: map['width'],
    );
  }
}

class DbMssgVideoFile extends DbMssgFile {
  DbMssgVideoFile({
    required super.mid,
    required super.me,
    required super.text,
    required super.timestamp,
    required super.type,
    required super.kid,
    required super.quoted_kid,
    required super.file,
    required super.mime,
    required super.name,
    required super.length,
    required super.size,
    required this.duration,
    required this.height,
    required this.width,
  });

  final int duration;
  final int? height;
  final int? width;

  factory DbMssgVideoFile.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as int;
    return DbMssgVideoFile(
      mid: map['mid'],
      me: map['me'],
      text: map['text'],
      timestamp: map['date'],
      type: map['type'],
      kid: map['kid'],
      quoted_kid: map['quoted_kid'],
      file: map['file'],
      mime: map['mime'],
      name: map['name'],
      length: map['length'],
      size: map['size'],
      duration: map['duration'],
      height: map['height'],
      width: map['width'],
    );
  }
}

class DbMssgDocumentFile extends DbMssgFile {
  DbMssgDocumentFile({
    required super.mid,
    required super.me,
    required super.text,
    required super.timestamp,
    required super.type,
    required super.kid,
    required super.quoted_kid,
    required super.file,
    required super.mime,
    required super.name,
    required super.length,
    required super.size,
    required this.count,
  });

  final int count;

  factory DbMssgDocumentFile.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as int;
    return DbMssgDocumentFile(
      mid: map['mid'],
      me: map['me'],
      text: map['text'],
      timestamp: map['date'],
      type: map['type'],
      kid: map['kid'],
      quoted_kid: map['quoted_kid'],
      file: map['file'],
      mime: map['mime'],
      name: map['name'],
      length: map['length'],
      size: map['size'],
      count: map['count'],
    );
  }
}


// // now for group

// class DbGroupMssg extends DbMssg {
//   DbGroupMssg({
//     required super.mid,
//     required super.me,
//     required super.text,
//     required super.timestamp,
//     required super.type,
//     required this.fromId,
//   });

//   final int fromId;
// }
