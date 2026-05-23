import 'dart:typed_data';

/// Stub para plataformas não-web.
/// No mobile/desktop, o Firebase Storage usa putData diretamente.
dynamic createBlobForWeb(Uint8List bytes, String mimeType) {
  throw UnsupportedError('createBlobForWeb só deve ser chamado no Flutter Web.');
}
