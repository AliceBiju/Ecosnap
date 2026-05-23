// Stub para plataformas não-web (mobile/desktop).
// No mobile, o SessionManager usa SharedPreferences diretamente.
// Estas funções nunca serão chamadas no mobile.

void saveToLocalStorage(String key, String value) {
  throw UnsupportedError('localStorage is only available on web.');
}

String? getFromLocalStorage(String key) {
  throw UnsupportedError('localStorage is only available on web.');
}

void removeFromLocalStorage(String key) {
  throw UnsupportedError('localStorage is only available on web.');
}
