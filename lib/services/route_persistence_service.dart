import 'package:shared_preferences/shared_preferences.dart';

class RoutePersistenceService {
  RoutePersistenceService(this._prefs);

  static const String _lastRouteKey = 'emplake_last_visited_route';
  final SharedPreferences _prefs;

  static Future<RoutePersistenceService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return RoutePersistenceService(prefs);
  }

  /// Retorna a última rota válida salva, ou '/difficulty' como padrão.
  String getSavedRoute() {
    final saved = _prefs.getString(_lastRouteKey);
    if (saved == null || saved.isEmpty || saved == '/login') {
      return '/difficulty';
    }
    return saved;
  }

  /// Salva a rota atual (ignora a tela de login).
  Future<void> saveRoute(String location) async {
    if (location == '/login' || location.isEmpty) return;
    await _prefs.setString(_lastRouteKey, location);
  }

  /// Limpa a rota salva ao sair da conta.
  Future<void> clearRoute() async {
    await _prefs.remove(_lastRouteKey);
  }
}