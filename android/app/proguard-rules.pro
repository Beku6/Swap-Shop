# Flutter engine/runtime
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# Firebase component discovery
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
-keep class com.google.firebase.provider.FirebaseInitProvider { *; }

# Firebase Messaging entry points
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Keep annotations used by Firebase / Play Services reflective loading
-keepattributes *Annotation*
