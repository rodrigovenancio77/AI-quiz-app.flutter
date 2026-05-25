import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _googleScopes = ['profile', 'email'];

Future<void>? _googleSignInInitFuture;

Future<void> _ensureGoogleSignInInitialized() {
  _googleSignInInitFuture ??= GoogleSignIn.instance.initialize();
  return _googleSignInInitFuture!;
}

Future<UserCredential?> googleSignInFunc() async {
  if (kIsWeb) {
    return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }

  await _ensureGoogleSignInInitialized();
  await signOutWithGoogle().catchError((_) => null);

  GoogleSignInAccount account;
  try {
    account = await GoogleSignIn.instance.authenticate(
      scopeHint: _googleScopes,
    );
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return null;
    }
    rethrow;
  }

  final auth = account.authentication;
  final authorization = await account.authorizationClient
      .authorizeScopes(_googleScopes);
  final credential = GoogleAuthProvider.credential(
    idToken: auth.idToken,
    accessToken: authorization.accessToken,
  );
  return FirebaseAuth.instance.signInWithCredential(credential);
}

Future<void> signOutWithGoogle() async {
  await _ensureGoogleSignInInitialized();
  await GoogleSignIn.instance.signOut();
}
