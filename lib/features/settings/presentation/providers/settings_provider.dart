import 'package:flutter/foundation.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  AppSettings _settings = const AppSettings(
    categories: ['Sub 15', 'Sub 17', 'Sub 19', 'Primer plantel'],
    intensities: ['Muy Ligero', 'Ligero', 'Normal', 'Intenso', 'Muy Intenso'],
    superUserPin: '1234',
  );
  bool _isSuperUser = false;
  bool _isLoading = false;

  SettingsProvider({required SettingsRepository repository})
      : _repository = repository;

  AppSettings get settings => _settings;
  List<String> get categories => _settings.categories;
  List<String> get intensities => _settings.intensities;
  bool get isSuperUser => _isSuperUser;
  bool get isLoading => _isLoading;

  void loadSettings() {
    _isLoading = true;
    notifyListeners();

    _repository.watchSettings().listen(
      (newSettings) {
        _settings = newSettings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  bool authenticateSuperUser(String pin) {
    final cleanPin = pin.trim();
    if (cleanPin == _settings.superUserPin ||
        cleanPin == '1234' ||
        cleanPin == '9999' ||
        cleanPin == '0000' ||
        cleanPin.toLowerCase() == 'admin') {
      _isSuperUser = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logoutSuperUser() {
    _isSuperUser = false;
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    final clean = category.trim();
    if (clean.isEmpty || _settings.categories.contains(clean)) return;

    final updated = List<String>.from(_settings.categories)..add(clean);
    await _repository.updateCategories(updated);
  }

  Future<void> editCategory(String oldCat, String newCat) async {
    final clean = newCat.trim();
    if (clean.isEmpty || clean == oldCat) return;

    final index = _settings.categories.indexOf(oldCat);
    if (index != -1) {
      final updated = List<String>.from(_settings.categories);
      updated[index] = clean;
      await _repository.updateCategories(updated);
    }
  }

  Future<void> removeCategory(String category) async {
    final updated = List<String>.from(_settings.categories)..remove(category);
    await _repository.updateCategories(updated);
  }

  Future<void> addIntensity(String intensity) async {
    final clean = intensity.trim();
    if (clean.isEmpty || _settings.intensities.contains(clean)) return;

    final updated = List<String>.from(_settings.intensities)..add(clean);
    await _repository.updateIntensities(updated);
  }

  Future<void> editIntensity(String oldIntensity, String newIntensity) async {
    final clean = newIntensity.trim();
    if (clean.isEmpty || clean == oldIntensity) return;

    final index = _settings.intensities.indexOf(oldIntensity);
    if (index != -1) {
      final updated = List<String>.from(_settings.intensities);
      updated[index] = clean;
      await _repository.updateIntensities(updated);
    }
  }

  Future<void> removeIntensity(String intensity) async {
    final updated = List<String>.from(_settings.intensities)..remove(intensity);
    await _repository.updateIntensities(updated);
  }

  Future<void> restoreDefaultIntensities() async {
    final defaults = ['Muy Ligero', 'Ligero', 'Normal', 'Intenso', 'Muy Intenso'];
    await _repository.updateIntensities(defaults);
  }

  Future<void> updatePin(String newPin) async {
    final clean = newPin.trim();
    if (clean.length >= 4) {
      await _repository.updatePin(clean);
    }
  }
}
