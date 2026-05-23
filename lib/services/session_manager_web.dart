import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('localStorage')
external JSObject get _localStorage;

/// Salva um valor no localStorage do browser.
void saveToLocalStorage(String key, String value) {
  _localStorage.callMethod('setItem'.toJS, key.toJS, value.toJS);
}

/// Lê um valor do localStorage do browser. Retorna null se não existir.
String? getFromLocalStorage(String key) {
  final result = _localStorage.callMethod('getItem'.toJS, key.toJS);
  if (result == null || result.isNull || result.isUndefined) return null;
  return (result as JSString).toDart;
}

/// Remove um valor do localStorage do browser.
void removeFromLocalStorage(String key) {
  _localStorage.callMethod('removeItem'.toJS, key.toJS);
}
