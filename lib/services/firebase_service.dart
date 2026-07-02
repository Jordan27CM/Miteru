import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // Cerrar Sesión
  static Future<void> logout() async {
    await _auth.signOut();
    // Cerramos sesión también en Google para que no recuerde la cuenta obligatoriamente
    try {
      if (!kIsWeb) await GoogleSignIn().signOut();
    } catch (e) {
      // Ignorar errores al cerrar sesión en Google si no estaba usando Google
    }
  }

  // Iniciar Sesión con Google
  static Future<User?> loginWithGoogle() async {
    try {
      if (kIsWeb) {
        // En Web usamos el Popup nativo de Firebase
        final googleProvider = GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(googleProvider);
        return credential.user;
      } else {
        // En móviles usamos el SDK nativo de Google
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Inicio de sesión con Google cancelado.');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
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
    return _db.ref('users/${user.uid}/favorites');
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
