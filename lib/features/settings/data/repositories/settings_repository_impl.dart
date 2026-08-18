import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;
  static const String collectionName = 'app_config';
  static const String documentId = 'general_settings';

  SettingsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference get _docRef =>
      _firestore.collection(collectionName).doc(documentId);

  @override
  Future<AppSettings> getSettings() async {
    try {
      final doc = await _docRef.get();
      if (!doc.exists) {
        final defaultSettings = const AppSettingsModel(
          categories: ['Sub 15', 'Sub 17', 'Sub 19', 'Primer plantel'],
          intensities: ['Ligero', 'Normal', 'Fuerte', 'Muy fuerte'],
          superUserPin: '1234',
        );
        await _docRef.set(defaultSettings.toFirestore());
        return defaultSettings;
      }
      return AppSettingsModel.fromFirestore(doc);
    } catch (e) {
      return const AppSettings(
        categories: ['Sub 15', 'Sub 17', 'Sub 19', 'Primer plantel'],
        intensities: ['Ligero', 'Normal', 'Fuerte', 'Muy fuerte'],
        superUserPin: '1234',
      );
    }
  }

  @override
  Stream<AppSettings> watchSettings() {
    return _docRef.snapshots().map((doc) => AppSettingsModel.fromFirestore(doc));
  }

  @override
  Future<void> updateCategories(List<String> categories) async {
    await _docRef.set({'categories': categories}, SetOptions(merge: true));
  }

  @override
  Future<void> updateIntensities(List<String> intensities) async {
    await _docRef.set({'intensities': intensities}, SetOptions(merge: true));
  }

  @override
  Future<void> updatePin(String newPin) async {
    await _docRef.set({'superUserPin': newPin}, SetOptions(merge: true));
  }
}
