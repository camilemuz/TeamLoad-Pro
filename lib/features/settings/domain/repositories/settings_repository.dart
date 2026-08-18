import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Stream<AppSettings> watchSettings();
  Future<void> updateCategories(List<String> categories);
  Future<void> updateIntensities(List<String> intensities);
  Future<void> updatePin(String newPin);
}
