import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _db = FirebaseDatabase.instance;


  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  static Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales incorrectas. Verifica tu correo y contraseña.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado en otra cuenta.';
      case 'invalid-email':
        return 'El formato del correo es inválido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      default:
        return 'Ocurrió un error inesperado ($code). Inténtalo de nuevo.';
    }
  }


  static DatabaseReference? _userFavoritesRef() {
    final user = currentUser;
    if (user == null) return null;
    return _db.ref('users/\${user.uid}/favorites');
  }

  static Future<void> addFavorite(int idMal) async {
    final ref = _userFavoritesRef();
    if (ref == null) throw Exception('Debes iniciar sesión para guardar animes.');
    await ref.child(idMal.toString()).set(true);
  }

  static Future<void> removeFavorite(int idMal) async {
    final ref = _userFavoritesRef();
    if (ref == null) throw Exception('Debes iniciar sesión para quitar animes.');
    await ref.child(idMal.toString()).remove();
  }

  static Stream<bool> isFavoriteStream(int idMal) {
    final ref = _userFavoritesRef();
    if (ref == null) return Stream.value(false);
    
    return ref.child(idMal.toString()).onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  static Future<List<int>> getFavoriteIds() async {
    final ref = _userFavoritesRef();
    if (ref == null) return [];
    
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.keys.map((k) => int.parse(k.toString())).toList();
    }
    return [];
  }
}
