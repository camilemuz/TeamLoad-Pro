import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/training_load.dart';
import '../../domain/repositories/training_load_repository.dart';
import '../models/training_load_model.dart';

class TrainingLoadRepositoryImpl implements TrainingLoadRepository {
  final FirebaseFirestore _firestore;

  TrainingLoadRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveTrainingLoad(TrainingLoad load) async {
    try {
      final model = TrainingLoadModel.fromEntity(load);
      final collection = _firestore.collection('training_loads');

      if (load.id.isEmpty) {
        await collection.add(model.toFirestore());
      } else {
        await collection.doc(load.id).set(model.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore save error (TrainingLoad): $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTrainingLoad(String id) async {
    try {
      await _firestore.collection('training_loads').doc(id).delete();
    } catch (e) {
      debugPrint('Firestore delete error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<TrainingLoad>> getTrainingLoads([String? userId]) {
    // Para modo equipo/kiosco y analista web: escucha todos los votos globales
    return _firestore
        .collection('training_loads')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return TrainingLoadModel.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<TrainingLoadModel>()
          .toList();
    });
  }
}
