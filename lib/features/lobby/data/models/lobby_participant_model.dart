import '../../domain/entities/lobby_participant.dart';

class LobbyParticipantModel {
  const LobbyParticipantModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.isHost,
  });

  factory LobbyParticipantModel.fromJson(Map<String, dynamic> json) => LobbyParticipantModel(
        id: json['id'] as String,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
        isHost: json['is_host'] as bool,
      );

  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final bool isHost;

  LobbyParticipant toEntity() => LobbyParticipant(
        id: id,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        isHost: isHost,
      );
}
