class DbChat {
  final int id;
  final int count;
  final String no;
  final String? groupName;
  final String? mssg;
  final int? date;

  DbChat({
    required this.id,
    required this.count,
    required this.no,
    this.groupName,
    this.mssg,
    this.date,
  });

  factory DbChat.fromMap(Map<String, dynamic> map) {
    return DbChat(
      id: map['id'],
      count: map['count'],
      no: map['no'],
      groupName: map['group_name'],
      mssg: map['mssg'],
      date: map['date'],
    );
  }
}
