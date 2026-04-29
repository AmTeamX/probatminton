class Party {
  final String id;
  final String hostId;
  final String hostName;
  final String title;
  final String gameName;
  final DateTime gameDateTime;
  final String location;
  final int capacity;
  final String? description;
  final String status;
  final int participantCount;
  final DateTime createdAt;

  Party({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.title,
    required this.gameName,
    required this.gameDateTime,
    required this.location,
    required this.capacity,
    this.description,
    required this.status,
    required this.participantCount,
    required this.createdAt,
  });

  bool get isOpen => status == 'OPEN';
  bool get isFull => status == 'FULL';
  bool get isCancelled => status == 'CANCELLED';
  bool get hasSpots => participantCount < capacity;

  factory Party.fromJson(Map<String, dynamic> json) => Party(
    id: json['id']?.toString() ?? '',
    hostId: json['host_id']?.toString() ?? '',
    hostName: json['host_name']?.toString() ?? 'Unknown',
    title: json['title']?.toString() ?? '',
    gameName: json['game_name']?.toString() ?? '',
    gameDateTime: json['game_date_time'] != null
        ? DateTime.parse(json['game_date_time'].toString())
        : DateTime.now(),
    location: json['location']?.toString() ?? '',
    capacity: json['capacity'] is int
        ? json['capacity']
        : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
    description: json['description']?.toString(),
    status: json['status']?.toString() ?? 'OPEN',
    participantCount: json['participant_count'] is int
        ? json['participant_count']
        : int.tryParse(json['participant_count']?.toString() ?? '0') ?? 0,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );
}

class PartyParticipant {
  final String id;
  final String partyId;
  final String userId;
  final DateTime joinedAt;

  PartyParticipant({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.joinedAt,
  });

  factory PartyParticipant.fromJson(Map<String, dynamic> json) =>
      PartyParticipant(
        id: json['id']?.toString() ?? '',
        partyId: json['party_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        joinedAt: json['joined_at'] != null
            ? DateTime.parse(json['joined_at'].toString())
            : DateTime.now(),
      );
}
