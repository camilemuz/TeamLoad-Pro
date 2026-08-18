import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;

  AuthRepositoryImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<String?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user?.uid;
    } catch (e) {
      // Si falla offline o primer inicio, retornar null o error
      return null;
    }
  }

  @override
  Stream<String?> get onAuthStateChanged {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
