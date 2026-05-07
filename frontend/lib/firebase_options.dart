// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This is a placeholder. You should ideally run `flutterfire configure` 
    // to generate the actual values for your project.
    return const FirebaseOptions(
      apiKey: 'AIzaSyBqzf-USA-c6ipz7yYQ3r_Rb43ITV0Izgw',
      appId: '1:1044286731796:android:c6e7593bd247bbad865901',
      messagingSenderId: '1044286731796',
      projectId: 'my-party-bf6e0',
    );
  }
}
