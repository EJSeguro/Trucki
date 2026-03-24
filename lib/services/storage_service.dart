import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

class StorageService {
  static const _matchesKey = 'trucki_matches';
  static const _team1Key = 'team_one_name';
  static const _team2Key = 'team_two_name';

  static Future<List<TruckiMatch>> getMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_matchesKey) ?? [];
    final list = raw
        .map((s) => TruckiMatch.fromJson(jsonDecode(s)))
        .toList();
    list.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return list;
  }

  static Future<void> saveMatch(TruckiMatch match) async {
    final prefs = await SharedPreferences.getInstance();
    final matches = await getMatches();
    // Replace if same id exists, else add
    final idx = matches.indexWhere((m) => m.id == match.id);
    if (idx >= 0) {
      matches[idx] = match;
    } else {
      matches.add(match);
    }
    await prefs.setStringList(
      _matchesKey,
      matches.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  static Future<void> deleteMatch(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final matches = await getMatches();
    matches.removeWhere((m) => m.id == id);
    await prefs.setStringList(
      _matchesKey,
      matches.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  static Future<String> getTeam1Name() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_team1Key) ?? 'Nós';
  }

  static Future<String> getTeam2Name() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_team2Key) ?? 'Eles';
  }

  static Future<void> saveTeamNames(String t1, String t2) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_team1Key, t1);
    await prefs.setString(_team2Key, t2);
  }
}
