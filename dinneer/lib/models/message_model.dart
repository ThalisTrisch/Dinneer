class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
    };
  }

  factory Message.fromJson(String id, Map<dynamic, dynamic> json) {
    return Message(
      id: id,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Usuário',
      text: json['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      imageUrl: json['imageUrl'],
    );
  }
}
