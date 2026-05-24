import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Blob')
@staticInterop
class _JSBlob {
  external factory _JSBlob(JSArray<JSAny?> parts, JSObject options);
}




dynamic createBlobForWeb(Uint8List bytes, String mimeType) {
  
  final jsUint8Array = bytes.buffer.toJS;

  
  final parts = <JSAny?>[jsUint8Array].toJS;

  
  final options = JSObject();
  options.setProperty('type'.toJS, mimeType.toJS);

  return _JSBlob(parts, options);
}
