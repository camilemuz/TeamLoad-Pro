import '../entities/training_load.dart';

abstract class TrainingLoadRepository {
  Future<void> saveTrainingLoad(TrainingLoad load);
  Future<void> deleteTrainingLoad(String id);
  Stream<List<TrainingLoad>> getTrainingLoads([String? userId]);
}
