import 'package:equatable/equatable.dart';

class TrainingLoad extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String category;
  final String intensity;

  const TrainingLoad({
    required this.id,
    required this.userId,
    required this.date,
    required this.category,
    required this.intensity,
  });

  @override
  List<Object?> get props => [id, userId, date, category, intensity];
}
