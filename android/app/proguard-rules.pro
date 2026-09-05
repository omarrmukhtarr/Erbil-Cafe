# Flutter and its plugins are reflected into from the engine.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Maps renders through classes resolved at runtime.
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Firebase Messaging resolves its service by name from the manifest.
-keep class com.google.firebase.** { *; }

# Flutter's engine references the Play Core split-install classes for deferred
# components. This app does not use deferred components and does not depend on
# Play Core, so R8 only needs to be told the absence is deliberate.
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
