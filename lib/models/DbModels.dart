class DbChat {
  final int cid;
  final String no;
  final String? groupName;
  final String? mssg;
  final int mssgType;
  final int? date;
  final int archived;
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
  });

  factory DbChat.fromMap(Map<String, dynamic> map) {
    return DbChat(
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
    );
  }
}

class DbMssg {
  final int mid;
  final int me;
  final String? text;
  final int timestamp;
  final String? file;
  final int type;

  DbMssg({
    required this.mid,
    required this.me,
    required this.text,
    required this.timestamp,
    required this.file,
    required this.type,
  });

  factory DbMssg.fromMap(Map<String, dynamic> map) {
    return DbMssg(
      mid: map['mid'],
      me: map['me'],
      text: map['text'],
      timestamp: map['date'],
      file: map['file'],
      type: map['type'],
    );
  }
}

class DbMssgs {
  final List<DbMssg> mssgs;
  final DbChat chat;

  DbMssgs({required this.mssgs, required this.chat});
}
