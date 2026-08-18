import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/training_load.dart';
import '../../domain/repositories/training_load_repository.dart';

enum DateFilter { day, week, month, all }

class TrainingLoadProvider extends ChangeNotifier {
  final TrainingLoadRepository _repository;
  List<TrainingLoad> _allLoads = [];
  String _selectedCategory = 'Todas';
  DateFilter _selectedDateFilter = DateFilter.day;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  TrainingLoadProvider({required TrainingLoadRepository repository})
      : _repository = repository;

  List<TrainingLoad> get allLoads => _allLoads;
  String get selectedCategory => _selectedCategory;
  DateFilter get selectedDateFilter => _selectedDateFilter;
  bool get isLoading => _isLoading;

  void subscribeToTeamLoads() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.getTrainingLoads().listen(
      (loads) {
        _allLoads = loads;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDateFilter(DateFilter filter) {
    _selectedDateFilter = filter;
    notifyListeners();
  }

  Future<bool> logTrainingLoad({
    required String userId,
    required DateTime date,
    required String category,
    required String intensity,
  }) async {
    final newLoad = TrainingLoad(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      date: date,
      category: category,
      intensity: intensity,
    );

    // Actualización reactiva instantánea
    _allLoads = [newLoad, ..._allLoads];
    notifyListeners();

    try {
      await _repository.saveTrainingLoad(newLoad);
      return true;
    } catch (e) {
      debugPrint('Error en guardado Firestore: $e');
      // No eliminamos del estado local para que el usuario no sienta pérdida de datos si hay modo offline
      return true;
    }
  }

  Future<void> deleteTrainingLoad(String id) async {
    _allLoads.removeWhere((item) => item.id == id);
    notifyListeners();

    try {
      await _repository.deleteTrainingLoad(id);
    } catch (e) {
      debugPrint('Error al eliminar en Firestore: $e');
    }
  }

  int getIntensityScore(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'ligero':
        return 25;
      case 'normal':
        return 50;
      case 'fuerte':
        return 75;
      case 'muy fuerte':
        return 100;
      default:
        return 50;
    }
  }

  // Filtrado de votos según categoría y periodo temporal seleccionado (Día, Semana, Mes, Todo)
  List<TrainingLoad> get filteredLoads {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monday = todayStart.subtract(Duration(days: todayStart.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    return _allLoads.where((load) {
      final matchesCategory =
          _selectedCategory == 'Todas' || load.category == _selectedCategory;

      bool matchesDate = true;
      if (_selectedDateFilter == DateFilter.day) {
        final loadDay = DateTime(load.date.year, load.date.month, load.date.day);
        matchesDate = loadDay == todayStart;
      } else if (_selectedDateFilter == DateFilter.week) {
        matchesDate = load.date.isAfter(monday.subtract(const Duration(seconds: 1)));
      } else if (_selectedDateFilter == DateFilter.month) {
        matchesDate = load.date.isAfter(monthStart.subtract(const Duration(seconds: 1)));
      }

      return matchesCategory && matchesDate;
    }).toList();
  }

  // Métricas del periodo seleccionado
  int get totalVotesInPeriod => filteredLoads.length;

  double get averageIntensityInPeriod {
    if (filteredLoads.isEmpty) return 0;
    final sum = filteredLoads.fold<int>(0, (acc, item) => acc + getIntensityScore(item.intensity));
    return sum / filteredLoads.length.toDouble();
  }

  // Distribución de votos por nivel de intensidad
  Map<String, int> get intensityDistribution {
    final map = <String, int>{
      'Ligero': 0,
      'Normal': 0,
      'Fuerte': 0,
      'Muy fuerte': 0,
    };
    for (final load in filteredLoads) {
      final key = load.intensity;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  // Desglose de votos por categoría
  Map<String, int> get categoryVoteCounts {
    final map = <String, int>{};
    for (final load in filteredLoads) {
      map[load.category] = (map[load.category] ?? 0) + 1;
    }
    return map;
  }

  // Carga Aguda (Media diaria de últimos 7 días)
  double get acuteLoad {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recent = _allLoads.where((l) => l.date.isAfter(sevenDaysAgo)).toList();
    if (recent.isEmpty) return 0;
    final total = recent.fold<int>(0, (sum, item) => sum + getIntensityScore(item.intensity));
    return total / 7.0;
  }

  // Carga Crónica (Media diaria de últimos 28 días)
  double get chronicLoad {
    final now = DateTime.now();
    final twentyEightDaysAgo = now.subtract(const Duration(days: 28));
    final recent = _allLoads.where((l) => l.date.isAfter(twentyEightDaysAgo)).toList();
    if (recent.isEmpty) return 0;
    final total = recent.fold<int>(0, (sum, item) => sum + getIntensityScore(item.intensity));
    return total / 28.0;
  }

  // Ratio ACWR (Acute:Chronic Workload Ratio)
  double get acwrRatio {
    final chronic = chronicLoad;
    if (chronic == 0) return acuteLoad > 0 ? 1.0 : 0.0;
    return acuteLoad / chronic;
  }

  // Datos para el gráfico de línea de la semana actual (Lunes a Domingo)
  Map<int, double> get weeklyDayLoads {
    final map = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final countMap = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monday = todayStart.subtract(Duration(days: todayStart.weekday - 1));

    for (final load in _allLoads) {
      if (_selectedCategory != 'Todas' && load.category != _selectedCategory) {
        continue;
      }
      if (load.date.isAfter(monday.subtract(const Duration(seconds: 1)))) {
        final weekday = load.date.weekday;
        final score = getIntensityScore(load.intensity).toDouble();
        map[weekday] = (map[weekday] ?? 0) + score;
        countMap[weekday] = (countMap[weekday] ?? 0) + 1;
      }
    }

    // Calcular el promedio por jugador de cada día
    for (int i = 1; i <= 7; i++) {
      final count = countMap[i] ?? 0;
      if (count > 0) {
        map[i] = map[i]! / count;
      }
    }

    return map;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
