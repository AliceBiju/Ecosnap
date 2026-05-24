import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('localStorage')
external JSObject get _localStorage;

void saveToLocalStorage(String key, String value) {
  _localStorage.callMethod('setItem'.toJS, key.toJS, value.toJS);
}

String? getFromLocalStorage(String key) {
  final result = _localStorage.callMethod('getItem'.toJS, key.toJS);
  if (result == null || result.isNull || result.isUndefined) return null;
  return (result as JSString).toDart;
}

void removeFromLocalStorage(String key) {
  _localStorage.callMethod('removeItem'.toJS, key.toJS);
}
