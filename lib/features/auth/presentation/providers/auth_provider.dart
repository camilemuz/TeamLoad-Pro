import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  String? _userId;
  bool _isLoading = false;

  AppAuthProvider({required AuthRepository repository}) : _repository = repository;

  String? get userId => _userId;
  bool get isAuthenticated => _userId != null;
  bool get isLoading => _isLoading;

  void init() {
    _userId = _repository.currentUserId;
    if (_userId == null) {
      signInAnonymously();
    }
    _repository.onAuthStateChanged.listen((uid) {
      _userId = uid;
      notifyListeners();
    });
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();

    _userId = await _repository.signInAnonymously();

    _isLoading = false;
    notifyListeners();
  }
}
