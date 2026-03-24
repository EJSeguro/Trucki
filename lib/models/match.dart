import 'dart:convert';

class ScoreEvent {
  final int team; // 1 or 2
  final int delta; // +1 or -1
  final int scoreAfter;
  final DateTime timestamp;

  ScoreEvent({
    required this.team,
    required this.delta,
    required this.scoreAfter,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'team': team,
        'delta': delta,
        'scoreAfter': scoreAfter,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScoreEvent.fromJson(Map<String, dynamic> j) => ScoreEvent(
        team: j['team'],
        delta: j['delta'],
        scoreAfter: j['scoreAfter'],
        timestamp: DateTime.parse(j['timestamp']),
      );
}

class TruckiMatch {
  final String id;
  final String teamOneName;
  final String teamTwoName;
  final int teamOneScore;
  final int teamTwoScore;
  final String? winner;
  final DateTime endedAt;
  final List<ScoreEvent> events;

  TruckiMatch({
    required this.id,
    required this.teamOneName,
    required this.teamTwoName,
    required this.teamOneScore,
    required this.teamTwoScore,
    this.winner,
    required this.endedAt,
    required this.events,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamOneName': teamOneName,
        'teamTwoName': teamTwoName,
        'teamOneScore': teamOneScore,
        'teamTwoScore': teamTwoScore,
        'winner': winner,
        'endedAt': endedAt.toIso8601String(),
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory TruckiMatch.fromJson(Map<String, dynamic> j) => TruckiMatch(
        id: j['id'],
        teamOneName: j['teamOneName'],
        teamTwoName: j['teamTwoName'],
        teamOneScore: j['teamOneScore'],
        teamTwoScore: j['teamTwoScore'],
        winner: j['winner'],
        endedAt: DateTime.parse(j['endedAt']),
        events: (j['events'] as List)
            .map((e) => ScoreEvent.fromJson(e))
            .toList(),
      );
}
