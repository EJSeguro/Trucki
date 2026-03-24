import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/storage_service.dart';

/// Holds the active game state so it persists when navigating away
class GameState extends ChangeNotifier {
  String _team1Name = 'Nós';
  String _team2Name = 'Eles';
  int _score1 = 0;
  int _score2 = 0;
  bool _gameActive = false;
  String _currentMatchId = '';
  List<ScoreEvent> _events = [];

  static const int maxScore = 12;

  String get team1Name => _team1Name;
  String get team2Name => _team2Name;
  int get score1 => _score1;
  int get score2 => _score2;
  bool get gameActive => _gameActive;
  List<ScoreEvent> get events => List.unmodifiable(_events);
  String get currentMatchId => _currentMatchId;

  bool get hasWinner => _score1 >= maxScore || _score2 >= maxScore;
  String? get winner {
    if (_score1 >= maxScore) return _team1Name;
    if (_score2 >= maxScore) return _team2Name;
    return null;
  }

  Future<void> loadTeamNames() async {
    _team1Name = await StorageService.getTeam1Name();
    _team2Name = await StorageService.getTeam2Name();
    notifyListeners();
  }

  void startNewGame() {
    _score1 = 0;
    _score2 = 0;
    _events = [];
    _gameActive = true;
    _currentMatchId = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  void changeScore(int team, int delta) {
    if (hasWinner) return;
    if (team == 1) {
      _score1 = (_score1 + delta).clamp(0, maxScore);
    } else {
      _score2 = (_score2 + delta).clamp(0, maxScore);
    }
    _events.add(ScoreEvent(
      team: team,
      delta: delta,
      scoreAfter: team == 1 ? _score1 : _score2,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> finishAndSave({bool restart = false}) async {
    final match = TruckiMatch(
      id: _currentMatchId,
      teamOneName: _team1Name,
      teamTwoName: _team2Name,
      teamOneScore: _score1,
      teamTwoScore: _score2,
      winner: winner,
      endedAt: DateTime.now(),
      events: List.from(_events),
    );
    await StorageService.saveMatch(match);
    if (restart) {
      startNewGame();
    } else {
      _gameActive = false;
    }
  }
}
