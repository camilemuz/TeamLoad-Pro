import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final List<String> categories;
  final List<String> intensities;
  final String superUserPin;

  const AppSettings({
    required this.categories,
    required this.intensities,
    this.superUserPin = '1234',
  });

  @override
  List<Object?> get props => [categories, intensities, superUserPin];
}
