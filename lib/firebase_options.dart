
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC5aTDTjpq_TOodczzlTLXIb6VB7j3eYRc',
    appId: '1:777495629350:web:55f62e97d552999b3ee0e7',
    messagingSenderId: '777495629350',
    projectId: 'teste-847fc',
    authDomain: 'teste-847fc.firebaseapp.com',
    storageBucket: 'teste-847fc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARJIaik_h8lKBbeEyDYJcsCHWFJAl-sWU',
    appId: '1:777495629350:android:1685e4300b12548a3ee0e7',
    messagingSenderId: '777495629350',
    projectId: 'teste-847fc',
    storageBucket: 'teste-847fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5aTDTjpq_TOodczzlTLXIb6VB7j3eYRc',
    appId: '1:777495629350:web:55f62e97d552999b3ee0e7',
    messagingSenderId: '777495629350',
    projectId: 'teste-847fc',
    storageBucket: 'teste-847fc.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5aTDTjpq_TOodczzlTLXIb6VB7j3eYRc',
    appId: '1:777495629350:web:55f62e97d552999b3ee0e7',
    messagingSenderId: '777495629350',
    projectId: 'teste-847fc',
    storageBucket: 'teste-847fc.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC5aTDTjpq_TOodczzlTLXIb6VB7j3eYRc',
    appId: '1:777495629350:web:55f62e97d552999b3ee0e7',
    messagingSenderId: '777495629350',
    projectId: 'teste-847fc',
    authDomain: 'teste-847fc.firebaseapp.com',
    storageBucket: 'teste-847fc.firebasestorage.app',
  );
}