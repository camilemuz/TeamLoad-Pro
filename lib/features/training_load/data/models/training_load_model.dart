import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/training_load.dart';

class TrainingLoadModel extends TrainingLoad {
  const TrainingLoadModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.category,
    required super.intensity,
  });

  factory TrainingLoadModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    DateTime parsedDate;
    final rawDate = data['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return TrainingLoadModel(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      date: parsedDate,
      category: data['category']?.toString() ?? '',
      intensity: data['intensity']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'category': category,
      'intensity': intensity,
    };
  }

  factory TrainingLoadModel.fromEntity(TrainingLoad entity) {
    return TrainingLoadModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      category: entity.category,
      intensity: entity.intensity,
    );
  }
}
