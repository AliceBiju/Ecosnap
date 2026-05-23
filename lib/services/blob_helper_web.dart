import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Blob')
@staticInterop
class _JSBlob {
  external factory _JSBlob(JSArray<JSAny?> parts, JSObject options);
}


/// Cria um Blob JavaScript a partir de bytes Dart.
/// Usado exclusivamente no Flutter Web para upload no Firebase Storage.
dynamic createBlobForWeb(Uint8List bytes, String mimeType) {
  // Converte os bytes para um Uint8Array JS
  final jsUint8Array = bytes.buffer.toJS;

  // Empacota num array JS de partes
  final parts = <JSAny?>[jsUint8Array].toJS;

  // Cria o objeto de opções
  final options = JSObject();
  options.setProperty('type'.toJS, mimeType.toJS);

  return _JSBlob(parts, options);
}
