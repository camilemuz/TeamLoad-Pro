abstract class AuthRepository {
  Future<String?> signInAnonymously();
  Stream<String?> get onAuthStateChanged;
  Future<void> signOut();
  String? get currentUserId;
}
