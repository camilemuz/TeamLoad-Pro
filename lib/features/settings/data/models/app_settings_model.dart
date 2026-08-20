import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.categories,
    required super.intensities,
    super.superUserPin = '1234',
  });

  factory AppSettingsModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      return const AppSettingsModel(
        categories: ['Sub 15', 'Sub 17', 'Sub 19', 'Primer plantel'],
        intensities: ['Muy Ligero', 'Ligero', 'Normal', 'Intenso', 'Muy Intenso'],
        superUserPin: '1234',
      );
    }
    final data = doc.data() as Map<String, dynamic>;
    return AppSettingsModel(
      categories: List<String>.from(data['categories'] ?? ['Sub 15', 'Sub 17', 'Sub 19', 'Primer plantel']),
      intensities: List<String>.from(data['intensities'] ?? ['Muy Ligero', 'Ligero', 'Normal', 'Intenso', 'Muy Intenso']),
      superUserPin: data['superUserPin'] ?? '1234',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categories': categories,
      'intensities': intensities,
      'superUserPin': superUserPin,
    };
  }
}
