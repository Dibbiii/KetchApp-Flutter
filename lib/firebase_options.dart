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
    apiKey: 'AIzaSyBjG39IYX0pWkn6cHTLCEbXAU2C5pI21DE',
    appId: '1:1049541862968:web:1ce1149572d42bd6d528cd',
    messagingSenderId: '1049541862968',
    projectId: 'testalebrutto',
    authDomain: 'testalebrutto.firebaseapp.com',
    storageBucket: 'testalebrutto.firebasestorage.app',
    measurementId: 'G-6B1DP28B0T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMA14zU26YiyDeh-HlemBrCSVaoqbtiu0',
    appId: '1:1049541862968:android:08618ab4c347426cd528cd',
    messagingSenderId: '1049541862968',
    projectId: 'testalebrutto',
    storageBucket: 'testalebrutto.firebasestorage.app',
    androidClientId:
        '1049541862968-889r2k03phkb1c2gk6l75cobpid1k7m0.apps.googleusercontent.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHOUd3jeH5HAgGpnEpUothkIa9UwrzNso',
    appId: '1:1049541862968:ios:3cc3d77d12df491bd528cd',
    messagingSenderId: '1049541862968',
    projectId: 'testalebrutto',
    storageBucket: 'testalebrutto.firebasestorage.app',
    androidClientId: '1049541862968-889r2k03phkb1c2gk6l75cobpid1k7m0.apps.googleusercontent.com',
    iosClientId: '1049541862968-fklmqnvph4ven6tmfci521n13h6bndqu.apps.googleusercontent.com',
    iosBundleId: 'com.example.ketchappFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBHOUd3jeH5HAgGpnEpUothkIa9UwrzNso',
    appId: '1:1049541862968:ios:3cc3d77d12df491bd528cd',
    messagingSenderId: '1049541862968',
    projectId: 'testalebrutto',
    storageBucket: 'testalebrutto.firebasestorage.app',
    androidClientId: '1049541862968-889r2k03phkb1c2gk6l75cobpid1k7m0.apps.googleusercontent.com',
    iosClientId: '1049541862968-fklmqnvph4ven6tmfci521n13h6bndqu.apps.googleusercontent.com',
    iosBundleId: 'com.example.ketchappFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjG39IYX0pWkn6cHTLCEbXAU2C5pI21DE',
    appId: '1:1049541862968:web:dce345b9f6c150ded528cd',
    messagingSenderId: '1049541862968',
    projectId: 'testalebrutto',
    authDomain: 'testalebrutto.firebaseapp.com',
    storageBucket: 'testalebrutto.firebasestorage.app',
    measurementId: 'G-03YL3FXRV0',
  );

}